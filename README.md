Hey, thank's for downloading this buggy template. I'll most likely link a video tutorial explaining how this works with a newer, better version just incase you couldn't figure it out, however, if it doesn't function in preview window properly, it could be due to replit not loading the .html file fully. If in such case, just simply remix the main template:
https://replit.com/@o-wow/template

BACKEND KEYWORDS - Lua Code Generation
VARIABLES AND DATA
<local> [text] = local ___N = [[text]]
<local> [number] = local ___N = [number]
<local> <time> = local ___N = os.date()
<local> <guess> [min],[max] = local ___N = math.random(min,max)
<local> <read> = local ___N = io.open('filename','r'):read('*a')
<local> function = local function ___N(___N+1) [statements] <done>
<basket> [val1],[val2],[val3] = local ___N = {val1,val2,val3}
CONTROL FLOW
<well> [condition] = if [condition] then
<done> = end
<for> [var]=[start],[end] = for [var]=[start],[end] do
<revive> = while true do
<revive> <sleep> [seconds] = while os.execute('sleep [seconds]') do
OUTPUT
<print> [text] = print('text')
<print> [variable] = print(variable)
<print> <time> = print(os.date())
<write> [text] = io.write('text')
<write> [variable] = io.write(variable)
<write> <time> = io.write(os.date())
FILE OPERATIONS
<create> [filename] = local ___N = io.open('filename','w')
___N <state> [content] = ___N:write(content)
___N <state> [content] <close> = ___N:write(content):close()
___N <read> = io.open('filename','r'):read()
TIMING
<sleep> [seconds] = os.execute('sleep [seconds]')
<time> = os.date()
RAW LUA
<lua> [any lua code] = [any lua code]
VARIABLE REFERENCE
___1 = first variable created
___2 = second variable created
___3 = third variable created
___N = Nth variable created
MATH OPERATIONS
<print> [num1] + [num2] = print(num1 + num2)
<print> [num1] - [num2] = print(num1 - num2)
<print> [num1] * [num2] = print(num1 * num2)
<print> [num1] / [num2] = print(num1 / num2)
================================================================================
FRONTEND KEYWORDS - HTML Generation
PAGE SETUP
fill: [color] = body style background-color:[color]
aupd: = auto-update content every 1 second
TEXT DISPLAY
display: [text] = h2 element 15px font size with [text]
displayx: [text] = h2 element 24px font size with [text]
IMAGES
attach: [path] = img 70px x 70px from [path]
attachx: [path] = img 240px x 240px from [path]
attachl: [path] = img 240px x 420px from [path]
attach: [path] position: [align] = img with alignment [align]
POSITIONING
position: center = text-align:center
position: left = text-align:left or class img-left
position: right = text-align:right or class img-right
position: top = class img-top
position: bottom = class img-bottom
position: middle = class img-middle
IFRAMES
linkframe: [url] = iframe 15% x 15% from [url]
linkframex: [url] = iframe 100% x 55% from [url]
linkframe: [url] position: [align] = iframe with alignment [align]
linkframex: [url] position: [align] = iframe with alignment [align]
STYLING
xy: [scale] = transform scale([scale])
rgb: [color] = color:[color]
bracket: = opens styled anchor tag

EXAMPLE PROGRAMS
EXAMPLE 1 - BASIC OUTPUT
<local> Hello World
<print> ___1
Output Lua:
local ___1 = [[Hello World]]
print(___1)
EXAMPLE 2 - CONDITIONAL
<local> <guess> 1,100
<well> ___1 > 50
<print> Big number
<done>
Output Lua:
local ___1 = math.random(1,100)
if ___1 > 50 then
print('Big number')
end
EXAMPLE 3 - LOOP
<local> 0
<revive> <sleep> 1
<lua> ___1 = ___1 + 1
<print> ___1
<done>
Output Lua:
local ___1 = 0
while os.execute('sleep 1') do
___1 = ___1 + 1
print(___1)
end
EXAMPLE 4 - FOR LOOP
<for> i=1,10
<print> Iteration
<print> i
<done>
Output Lua:
for i=1,10 do
print('Iteration')
print(i)
end
EXAMPLE 5 - FILE WRITE
<create> output.txt
___1 <state> Hello from file <close>
Output Lua:
local ___1 = io.open('output.txt','w')
___1:write(Hello from file):close()
EXAMPLE 6 - FILE READ
<create> data.txt
<local> <read>
<print> ___2
Output Lua:
local ___1 = io.open('data.txt','w')
local ___2 = io.open('data.txt','r'):read('*a')
print(___2)
EXAMPLE 7 - FUNCTION
<local> function
<print> Function executed
<done>
<lua> ___1()
Output Lua:
local function ___1(___2)
print('Function executed')
end
___1()
EXAMPLE 8 - MATH
<local> 10
<local> 5
<print> ___1 + ___2
<print> ___1 * ___2
Output Lua:
local ___1 = 10
local ___2 = 5
print(___1 + ___2)
print(___1 * ___2)
EXAMPLE 9 - DATE TIME
<local> <time>
<print> Current time:
<print> ___1
Output Lua:
local ___1 = os.date()
print('Current time:')
print(___1)
EXAMPLE 10 - ARRAY
<basket> apple,banana,cherry
<lua> print(___1[1])
Output Lua:
local ___1 = {apple,banana,cherry}
print(___1[1])
EXAMPLE 11 - SIMPLE WEB PAGE
fill: #ffffff
displayx: My Website
display: Welcome to my site
attach: logo.png position: center
Output HTML:
body style background-color:#ffffff
h2 24px My Website
h2 15px Welcome to my site
img 70px x 70px logo.png centered
EXAMPLE 12 - STYLED TEXT
bracket:
rgb: #ff0000
displayx: Red Title
Output HTML:
a style color:#ff0000
h2 24px Red Title
EXAMPLE 13 - IMAGE GALLERY
fill: #000000
displayx: Photo Gallery
attachx: photo1.jpg position: left
attachx: photo2.jpg position: right
Output HTML:
black background
24px title Photo Gallery
240px images aligned left and right
EXAMPLE 14 - EMBEDDED CONTENT
fill: #2c3e50
displayx: Video Section
linkframex: https://youtube.com/embed/videoid
Output HTML:
dark background
24px title
100% x 55% iframe with video
EXAMPLE 15 - 3D SCENE
fill: #000000
world: models/character.fbx
displayx: 3D Demo
Output HTML:
black background
Three.js scene with FBX model
WASD movement controls
Mouse look with right-click
EXAMPLE 16 - SCALED ELEMENT
xy: 2
displayx: Big Text
Output HTML:
transform scale(2) wrapper
24px text scaled 2x
EXAMPLE 17 - MIXED BACKEND FRONTEND
<local> My Portfolio
<print> ___1
fill: #ffffff
displayx: ___1
display: Created with custom language
Output Lua:
local ___1 = [[My Portfolio]]
print(___1)
Output HTML:
white background
24px My Portfolio
15px Created with custom language
EXAMPLE 18 - COMPLEX LOGIC
<local> <guess> 1,100
<print> Random number: ___1
<well> ___1 < 25
<print> Very small
<done>
<well> ___1 >= 25
<well> ___1 < 75
<print> Medium
<done>
<done>
<well> ___1 >= 75
<print> Very large
<done>
Output Lua:
local ___1 = math.random(1,100)
print('Random number: ___1')
if ___1 < 25 then
print('Very small')
end
if ___1 >= 25 then
if ___1 < 75 then
print('Medium')
end
end
if ___1 >= 75 then
print('Very large')
end
EXAMPLE 19 - COUNTDOWN
<local> 10
<revive>
<print> ___1
<sleep> 1
<lua> ___1 = ___1 - 1
<well> ___1 <= 0
<lua> break
<done>
<done>
<print> Done
Output Lua:
local ___1 = 10
while true do
print(___1)
os.execute('sleep 1')
___1 = ___1 - 1
if ___1 <= 0 then
break
end
end
print('Done')
EXAMPLE 20 - DATA LOGGER
<create> log.txt
<local> <time>
___1 <state> Log entry at: <close>
___1 <state> ___2 <close>
Output Lua:
local ___1 = io.open('log.txt','w')
local ___2 = os.date()
___1:write(Log entry at:):close()
___1:write(___2):close()
NOTES
INPUT FILE
Default filename: "o wow"
Change on lines: 26, 27, and bottom loop section
OUTPUT FILES
source/execute.lua - generated Lua code
source/index.html - generated HTML page
EXECUTION
Automatically runs: os.execute("luajit source/execute.lua")
Change luajit to lua if needed
VARIABLE COUNTER
Increments with: <local>, <create>, <local> function
Reference format: ___1, ___2, ___3, etc
CASE SENSITIVITY
Keywords work in any case
<LOCAL> = <local> = <Local>
FILL: = fill: = Fill:
BLOCK CLOSING
Every <well>, <revive>, <for> needs <done>
Blocks can be nested
DEBUG MODE
Set unnecessary_output = true on line 22
Shows debug messages during transpilation
