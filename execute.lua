print("")

-- [[ OPTIMIZED CONFIGURATION ]]
local TRAINING_ENABLED = false
local ___5 = 128
local num_layers = 5
local seq_len = 32
local ff_mult = 5
local lr = 0.000005
local max_steps = 10
local batch_size = 68

print(string.format("CONFIG: ___5=%d, Layers=%d, SeqLen=%d, Batch=%d, Steps=%d", ___5, num_layers, seq_len, batch_size, max_steps))

-- [[ WORD-LEVEL TOKENIZER ]]
print('loading reference')

local f = assert(io.open("source/reference.txt", "rb"))
local raw_text = f:read("*all")
f:close()

print(string.format("Loaded %d characters", #raw_text))

-- Normalize and split into words
raw_text = raw_text:gsub("[\r\n]+", " "):gsub("%s+", " "):lower()
raw_text = raw_text:gsub("([%.,%!%?;:])", " %1 ")

local words = {}
for word in raw_text:gmatch("%S+") do
  table.insert(words, word)

end

print(string.format("Split into %d words", #words))

-- Build vocabulary
local word_freq = {}
for _, word in ipairs(words) do
  word_freq[word] = (word_freq[word] or 0) + 1

end

local vocab = {["<PAD>"] = 1, ["<UNK>"] = 2, ["<START>"] = 3, ["<END>"] = 4}
local rev_vocab = {[1] = "<PAD>", [2] = "<UNK>", [3] = "<START>", [4] = "<END>"}
local next_id = 5

local sorted_words = {}
for word, freq in pairs(word_freq) do
  table.insert(sorted_words, {word = word, freq = freq})

end
table.sort(sorted_words, function(a, b) return a.freq > b.freq end)

for _, item in ipairs(sorted_words) do

if  item.freq >= 2 or next_id < 300 then
    vocab[item.word] = next_id
    rev_vocab[next_id] = item.word
    next_id = next_id + 1

end

end

local vocab_size = next_id - 1
print(string.format("Vocab size: %d tokens", vocab_size))

local function encode(text)
  local ids = {}
  text = text:lower():gsub("([%.,%!%?;:])", " %1 ")
for word in text:gmatch("%S+") do
    table.insert(ids, vocab[word] or 2)

end
  return ids

end

local function decode(ids)
  local parts = {}
for _, id in ipairs(ids) do

if  id > 4 then
      table.insert(parts, rev_vocab[id] or "")

end

end
  return table.concat(parts, " ")

end

local token_ids = encode(raw_text)
local total_tokens = #token_ids
print(string.format("Total tokens: %d\n", total_tokens))

-- [[ TENSOR CORE ]]
print("Simulating model",os.date())

local function FlatTensor(rows, cols)
  local t = {}
  local size = rows * cols
  local scale = math.sqrt(2.0 / (rows + cols))
for i = 1, size do
    t[i] = (math.random() - 0.5) * 2 * scale

end
  t.rows, t.cols, t.size = rows, cols, size
  t.grad = {}
  for i = 1, size do t.grad[i] = 0 end
  t.idx = function(_, r, c) return (r - 1) * cols + c end
  return t

end

local function ZeroFlatTensor(rows, cols)
  local t = {}
  local size = rows * cols
  for i = 1, size do t[i] = 0 end
  t.rows, t.cols, t.size = rows, cols, size
  t.grad = {}
  for i = 1, size do t.grad[i] = 0 end
  t.idx = function(_, r, c) return (r - 1) * cols + c end
  return t

end

local function matmul(a, b)
  local M, K, N = a.rows, a.cols, b.cols
  local out = ZeroFlatTensor(M, N)
for i = 1, M do
    local offset_a = (i - 1) * K
    local offset_out = (i - 1) * N
    for j = 1, N do
      local s = 0
      for k = 1, K do
        s = s + a[offset_a + k] * b[(k - 1) * N + j]

end
      out[offset_out + j] = s

end

end
  out._a, out._b = a, b
  return out

end

local function transpose_flat(t)
  local out = ZeroFlatTensor(t.cols, t.rows)
for r = 1, t.rows do
    local offset_r = (r - 1) * t.cols
    for c = 1, t.cols do
      out[(c - 1) * t.rows + r] = t[offset_r + c]

end

end
  out._original = t
  return out

end

local function add(a, b)
  local out = ZeroFlatTensor(a.rows, a.cols)
  for i = 1, a.size do out[i] = a[i] + b[i] end
  out._a, out._b = a, b
  return out

end

local function relu(x)
  local out = ZeroFlatTensor(x.rows, x.cols)
  for i = 1, x.size do out[i] = math.max(0, x[i]) end
  out._x = x
  return out

end

local function softmax(row)
  local m = row[1]
  for i = 2, row.size do if row[i] > m then m = row[i] end end
  local s = 0
  local out = ZeroFlatTensor(row.rows, row.cols)
  for i = 1, row.size do
    out[i] = math.exp(row[i] - m)
    s = s + out[i]

end
  local inv_s = 1 / s
  for i = 1, row.size do out[i] = out[i] * inv_s end
  out._row = row
  return out

end

local function sub(a,b)
  local out = ZeroFlatTensor(a.rows, a.cols)
  for i = 1, a.size do out[i] = a[i] - b[i] end
  out._a, out._b = a, b
  return out

end

local function mul(a, b)
  local out = ZeroFlatTensor(a.rows, a.cols)
  for i = 1, a.size do out[i] = a[i] * b[i] end
  out._a, out._b = a, b
  return out

end

local function scale(t, s)
  local out = ZeroFlatTensor(t.rows, t.cols)
  for i = 1, t.size do out[i] = t[i] * s end
  out._t, out._s = t, s
  return out

end

local function div(t, ___5)
  return scale(t, 1/___5)

end

local function layernorm(x, gamma, beta)
  local out = ZeroFlatTensor(x.rows, x.cols)
  local eps = 1e-5
for r = 1, x.rows do
    local row_start = (r - 1) * x.cols
    local row_sum = 0
    for c = 1, x.cols do row_sum = row_sum + x[row_start + c] end
    local row_mean = row_sum / x.cols
    local sq_diff_sum = 0
    for c = 1, x.cols do
      local diff = x[row_start + c] - row_mean
      sq_diff_sum = sq_diff_sum + diff * diff

end
    local row_var = sq_diff_sum / x.cols
    local inv_stddev = 1 / math.sqrt(row_var + eps)
    for c = 1, x.cols do
      local i = row_start + c
      local x_norm = (x[i] - row_mean) * inv_stddev
      out[i] = gamma[c] * x_norm + beta[c]

end

end
  out._x, out._gamma, out._beta = x, gamma, beta
  return out

end

-- [[ BACKPROP ]]

local function backprop(out, upstream_grad)
  for i = 1, out.size do out.grad[i] = out.grad[i] + upstream_grad[i] end
  

if  out._a and out._b and out._a.rows and out._b.rows then
    local a, b = out._a, out._b
    local M, K, N = a.rows, a.cols, b.cols
    
    for k = 1, K do
      local offset_b = (k - 1) * N
      for j = 1, N do
        local s = 0
        for i = 1, M do
          s = s + a[(i - 1) * K + k] * out.grad[(i - 1) * N + j]
        end
        if b.grad then b.grad[offset_b + j] = b.grad[offset_b + j] + s end

end

end
    
    for i = 1, M do
      local offset_a = (i - 1) * K
      local offset_out = (i - 1) * N
      for k = 1, K do
        local s = 0
        for j = 1, N do
          s = s + out.grad[offset_out + j] * b[(k - 1) * N + j]
        end
        if a.grad then a.grad[offset_a + k] = a.grad[offset_a + k] + s end

end

end
    
  elseif out._a and out._b then
    for i = 1, out.size do
      if out._a.grad then out._a.grad[i] = out._a.grad[i] + out.grad[i] end
      if out._b.grad then out._b.grad[i] = out._b.grad[i] + out.grad[i] end

end
  elseif out._x then

if  out._gamma then
      for i = 1, out.size do
        if out._x.grad then out._x.grad[i] = out._x.grad[i] + out.grad[i] end

end
    else
      for i = 1, out.size do
        if out._x.grad then 
          out._x.grad[i] = out._x.grad[i] + out.grad[i] * (out[i] > 0 and 1 or 0) 
        end

end

end
  elseif out._row then
    for i = 1, out.size do
      if out._row.grad then out._row.grad[i] = out._row.grad[i] + out.grad[i] end

end
  elseif out._original then
    local original = out._original
    for r = 1, original.rows do
      for c = 1, original.cols do
        if original.grad then 
          original.grad[original:idx(r, c)] = original.grad[original:idx(r, c)] + out.grad[out:idx(c, r)] 
        end

end

end
  elseif out._t then
    local t, s = out._t, out._s
    for i = 1, t.size do
      if t.grad then t.grad[i] = t.grad[i] + out.grad[i] * s end

end

end

end

local function backward(out, target)
  local loss_out = sub(out, target)
  local loss_sq = mul(loss_out, loss_out)
  local loss = 0
  for i = 1, loss_sq.size do loss = loss + loss_sq[i] end
  loss = loss / loss_sq.size
  
  local dloss_dout = scale(loss_out, 2 / out.size)
  backprop(out, dloss_dout)
  
  return loss

end

-- [[ MODEL ]]

local emb = FlatTensor(vocab_size, ___5)
local pos = FlatTensor(seq_len, ___5)
local out_w = FlatTensor(___5, vocab_size)
local gamma = FlatTensor(1, ___5)
local beta = ZeroFlatTensor(1, ___5)
for i = 1, ___5 do gamma[i] = 1 end

local layers = {}
for _ = 1, num_layers do
  table.insert(layers, {
    wq = FlatTensor(___5, ___5), wk = FlatTensor(___5, ___5), wv = FlatTensor(___5, ___5),
    wo = FlatTensor(___5, ___5), w1 = FlatTensor(___5, ___5 * ff_mult), w2 = FlatTensor(___5 * ff_mult, ___5),
    gn = FlatTensor(1, ___5), bn = ZeroFlatTensor(1, ___5),
    gff = FlatTensor(1, ___5), bff = ZeroFlatTensor(1, ___5)
  })
for i = 1, ___5 do
    layers[#layers].gn[i] = 1
    layers[#layers].gff[i] = 1

end

end

local params = {emb, out_w, pos}
for _, L in ipairs(layers) do
table.insert(params, L.wq); table.insert(params, L.wk); table.insert(params, L.wv)
table.insert(params, L.wo); table.insert(params, L.w1); table.insert(params, L.w2)

end

print(string.format("Model ready (%d parameters)\n", 
  vocab_size*___5 + seq_len*___5 + ___5*vocab_size + num_layers*(___5*___5*6 + ___5*___5*ff_mult*2)))

-- [[ FORWARD PASS ]]

local function forward_layer(x, L)
  local q = matmul(x, L.wq)
  local k = matmul(x, L.wk)
  local v = matmul(x, L.wv)
  
  local k_t = transpose_flat(k)
  local scores = matmul(q, k_t)
  scores = div(scores, math.sqrt(___5))
  
for i = 1, seq_len do
for j = i + 1, seq_len do
      scores[scores:idx(i, j)] = -1e9

end

end
  
  local attn_weights = ZeroFlatTensor(seq_len, seq_len)
for i = 1, seq_len do
    local row_start = (i - 1) * seq_len
    local row = ZeroFlatTensor(1, seq_len)
    for j = 1, seq_len do row[j] = scores[row_start + j] end
    local soft = softmax(row)
    for j = 1, seq_len do attn_weights[row_start + j] = soft[j] end

end
  
  local attn_output = matmul(attn_weights, v)
  local proj_output = matmul(attn_output, L.wo)
  
  local attn_res = add(x, proj_output)
  local attn_norm = layernorm(attn_res, L.gn, L.bn)
  
  local ff1 = matmul(attn_norm, L.w1)
  local ff_act = relu(ff1)
  local ff2 = matmul(ff_act, L.w2)
  
  local ff_res = add(attn_norm, ff2)
  local out = layernorm(ff_res, L.gff, L.bff)
  
  return out

end

local function forward(token_ids)
  local x = ZeroFlatTensor(seq_len, ___5)
  
for i = 1, seq_len do
    local token_id = token_ids[i] or 1
    local r_emb = (token_id - 1) * ___5
    local r_pos = (i - 1) * ___5
    local r_out = (i - 1) * ___5
    for j = 1, ___5 do
      x[r_out + j] = emb[r_emb + j] + pos[r_pos + j]

end

end
  
  local h = x
for _, L in ipairs(layers) do
    h = forward_layer(h, L)

end
  
  local logits = matmul(h, out_w)
  return logits

end

-- [[ OPTIMIZER ]]

local adam_m, adam_v = {}, {}
for i, p in ipairs(params) do
  adam_m[i] = ZeroFlatTensor(p.rows, p.cols)
  adam_v[i] = ZeroFlatTensor(p.rows, p.cols)

end

local function zero_grads()
for _, p in ipairs(params) do
    for i = 1, p.size do
      p.grad[i] = 0

end

end

end
local function adam_update(step)
  local beta1 = 0.9
  local beta2 = 0.999
  local eps = 1e-8
  local alpha = lr * math.sqrt(1 - beta2^step) / (1 - beta1^step)
  
for i, p in ipairs(params) do
    local m, v = adam_m[i], adam_v[i]
    for j = 1, p.size do
      m[j] = beta1 * m[j] + (1 - beta1) * p.grad[j]
      v[j] = beta2 * v[j] + (1 - beta2) * p.grad[j] * p.grad[j]
      p[j] = p[j] - alpha * m[j] / (math.sqrt(v[j]) + eps)

end

end

end

-- [[ TRAINING ]]

local function train_step(batch_starts)
  local total_loss = 0
  
for _, start_idx in ipairs(batch_starts) do
local ___438 = {}
    local target_ids = {}
    
    for i = 1, seq_len do
      ___438[i] = token_ids[start_idx + i - 1] or 1
      target_ids[i] = token_ids[start_idx + i] or 1

end
    
    local logits = forward(___438)
    
    local target_onehot = ZeroFlatTensor(seq_len, vocab_size)
    for i = 1, seq_len do
      local target_id = target_ids[i]
      target_onehot[(i - 1) * vocab_size + target_id] = 1

end
    
    local loss = backward(logits, target_onehot)
    total_loss = total_loss + loss

end
  
  return total_loss / batch_size

end


if  TRAINING_ENABLED and total_tokens > seq_len + batch_size then
  print("TRAINING MODEL\n")
  local start_time = os.clock()
  
  for step = 1, max_steps do
    zero_grads()
    local batch_starts = {}
    for b = 1, batch_size do
      local upper = math.max(1, total_tokens - seq_len)
table.insert(batch_starts, math.random(upper))

end

    local loss = train_step(batch_starts)
    adam_update(step)
    

if  step % 20 == 0 or step == 1 or step == max_steps then
      local elapsed = os.clock() - start_time
      local steps_per_sec = step / elapsed
      print(string.format("Step %3d/%d | Loss: %.4f | Speed: %.1f steps/sec", 
        step, max_steps, loss, steps_per_sec))

end

end
  
  local total_time = os.clock() - start_time
  print(string.format("\n Training complete in %.1f seconds\n",total_time))

end

-- [[ GENERATION ]]

local function generate(prompt, max_new_tokens, temperature)
  temperature = temperature or math.random(0.255,0.285)
  
  local current_ids = encode(prompt)
  if #current_ids == 0 then current_ids = {3} end
  
  print(string.format("Prompt:'%s'", prompt))
  
  for i = 1, max_new_tokens do
    local ___438 = {}
    for j = 1, seq_len do
      local k = #current_ids - seq_len + j
      ___438[j] = (k > 0) and current_ids[k] or 1

end
    
    local logits = forward(___438)
    
    local last_token_logits = ZeroFlatTensor(1, vocab_size)
    local logit_start = (seq_len - 1) * vocab_size
    for j = 1, vocab_size do
      last_token_logits[j] = logits[logit_start + j] / temperature

end
    
    local probs = softmax(last_token_logits)
    local r = math.random()
    local cumulative_prob = 0
    local next_id = 1
    
    for j = 1, vocab_size do
      cumulative_prob = cumulative_prob + probs[j]
      if r < cumulative_prob then
        next_id = j
        break

end

end
    
    table.insert(current_ids, next_id)
    
    if next_id == 4 then break end

end
  
print("RESULT:")

local f = io.open("source/bot.html","w")
if f then f:write(decode(current_ids) .. "."); f:close() end

end
local = [[You are a patient, beginner-friendly tutor for basic math, science, and grammar, designed to guide a slightly slow learner. In math, always explain addition, subtraction, multiplication, division, fractions, decimals, percentages, and simple algebra step by step, showing examples and intermediate steps, explaining why each step works. In science, focus on introductory physics (motion, forces, energy), chemistry (elements, molecules, reactions), and biology (cells, human body basics, plants), always using simple language and examples. In grammar, teach spelling, punctuation, sentence structure, parts of speech, capitalization, and basic writing rules with clear examples. For every answer, break steps down slowly, never skip reasoning, avoid jargon, random numbers, or unrelated topics, and ensure answers are clear, accurate, and beginner-friendly. Always assume the user may not understand concepts immediately, so provide extra explanation, analogies, and warnings about common mistakes.]]
local ___537 = math.random(15,15)
local gen = generate(___536.."\r",___537,temperature,".")
local function save_model(filename)
    local f = assert(io.open(filename, "wb"))

    local function save_tensor(t)
f:write(t.rows .. " " .. t.cols .. "\n")
for i = 1, t.size do
f:write(t[i] .. "\n")

end

end

-- Save main tensors
save_tensor(emb)
save_tensor(out_w)
save_tensor(pos)

-- Save layers
for _, L in ipairs(layers) do
save_tensor(L.wq)
save_tensor(L.wk)
save_tensor(L.wv)
save_tensor(L.wo)
save_tensor(L.w1)
save_tensor(L.w2)
save_tensor(L.gn)
save_tensor(L.bn)
save_tensor(L.gff)
save_tensor(L.bff)

end

f:close()
print("Model saved to " .. filename)

end
local ___571 = [[false]]
if ___571 then
--save_model("source/model.txt")

end
