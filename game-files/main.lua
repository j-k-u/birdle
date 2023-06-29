io.stdout:setvbuf("no")
require("validWords")
require("answers")
listOfLetters = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'}
topRow = {'q','w','e','r','t','y','u','i','o','p'}
midRow = {'a','s','d','f','g','h','j','k','l'}
botRow = {'z','x','c','v','b','n','m'}

notoSans = love.graphics.newFont("NotoSansMono-SemiBold.ttf", 40)
openSans = love.graphics.newFont("OpenSans-SemiBold.ttf", 20)
icon = love.image.newImageData("icon.png")

function love.load()
  love.window.setMode(600,800, {resizable=true})
  --love.window.setTitle("BIRDLE")
  --love.window.setIcon(icon)

  love.graphics.setDefaultFilter("nearest", "nearest", 1)
  y=200 --bird starting height
  
  --starting word
  myWord = 'birds'
  birdLetter = 'r'
  letter1 = 'b'
  letter2 = 'i'
  letter3 = 'r'
  letter4 = 'd'
  letter5 = 's'
  
  --starting flags
  correctWord = false
  validWord = false
  passed = false
  prevPassed = false
  dead = false
  
  --starting pipe
  pipeWidth = 50
  pipeSpaceHeight = 100
  pipeSpaceY = 150
  pipeX = 600
  pipeY = 50
  pipeSpeed = 100

  --font
  mainFont = notoSans
  
  --bird
  birdSpeed = 30
  gravity = 80
  birdX = 100
  
  --score
  score = 0
  
end

function reload()
  y=200 --bird starting height
  
  --starting word
  myWord = 'birds'
  birdLetter = 'r'
  letter1 = 'b'
  letter2 = 'i'
  letter3 = 'r'
  letter4 = 'd'
  letter5 = 's'
  
  --starting flags
  correctWord = false
  validWord = false
  passed = false
  prevPassed = false
  dead = false
  
  --starting pipe
  pipeWidth = 50
  pipeSpaceHeight = 100
  pipeSpaceY = 150
  pipeX = 600
  pipeY = 50
  pipeSpeed = 100

  --font
  mainFont = notoSans
  
  --bird
  birdSpeed = 30
  gravity = 80
  birdX = 100
  
  --score
  score = 0
  
end

function love.keypressed(key)
  y = y - birdSpeed
  if search_value(listOfLetters, key) then
    birdLetter = key
  end
  if dead and key == "escape" then
    reload()
  end
  
end
  
function love.mousepressed(mouseX, mouseY, button, istouch)
  y = y - birdSpeed
  if mouseY > 550 and mouseY < 600 and mouseX > 50 and mouseX < 550 then
    i = math.floor(mouseX/50)
    key = topRow[i]
    birdLetter = key
  elseif mouseY > 625 and mouseY < 675 and mouseX > 75 and mouseX < 525 then
    i = math.floor((mouseX-25)/50)
    key = midRow[i]
    birdLetter = key
  elseif mouseY > 700 and mouseY < 750 and mouseX > 125 and mouseX < 475 then
    i = math.floor((mouseX-75)/50)
    key = botRow[i]
    birdLetter = key
  end
  
  if dead then
    if mouseY > 388 and mouseY < 438 and mouseX > 200 and mouseX < 400 then
      reload()
    end
  end
end
function love.update(dt)
  y = y + gravity*dt
  if y > 450 then
    --print("you died")
    y=450
    youLose()
  elseif y < 0 then
    y=0
  end
  
  pipeX = pipeX - (pipeSpeed*dt)
  if pipeX < -50 then
    newPipe()
  end
  
  --check collision
  --birdY = y
  if collision(100, y, 50, pipeX, pipeY+100, pipeWidth, 100) then
    youLose()
  end
  
  
  --check word validity
  prevPassed = passed
  if pipeX>100 then
    passed = false
  else
    passed = true
  end
  
  if passed and not prevPassed then
    checkWord()
    --print(letter1..letter2..birdLetter..letter4..letter5)
  end
end

function love.draw()
  if dead then
    --background
      love.graphics.setColor(.9,.9,.9)
      love.graphics.rectangle('fill', 0, 0, 600, 800)
    
    --pausescreen
      love.graphics.setColor(.3, .3, .3)
      love.graphics.rectangle('fill', 10, 10, 580, 480, 15, 15)
      
    --info
      love.graphics.setColor(0,.5,0) --green
      love.graphics.rectangle('fill', 200, 188, 200, 50, 10, 10) --your score box
      love.graphics.setColor(.6,.6,.6)
      love.graphics.rectangle('fill', 200, 388, 200, 50, 10, 10) --continue box
      love.graphics.setColor(1,1,1)
      love.graphics.setFont(mainFont)
      love.graphics.print("Try Again", 185, 100)
      love.graphics.setFont(openSans)
      love.graphics.print("Your Score: "..score, 230, 200)
      love.graphics.print("The word was "..string.upper(myWord), 195, 250)
      love.graphics.setColor(.9,.9,0)
      love.graphics.print("continue [esc]", 230, 400)
      
      
    --keyboard
      love.graphics.setColor(.6,.6,.6)
      love.graphics.rectangle('fill', 0, 500, 600, 300)
      drawKeys()
  else
      --background
      love.graphics.setColor(.9,.9,.9)
      love.graphics.rectangle('fill', 0, 0, 600, 800)
      
      --score
      love.graphics.setColor(0,0,0)
      love.graphics.setFont(openSans)
      love.graphics.print("Score: "..score)
      
      --bird
      if correctWord then 
        love.graphics.setColor(0,.75,0)
      elseif validWord then
        love.graphics.setColor(.9,.9,0)
      else
        love.graphics.setColor(1,1,1)
      end
      love.graphics.rectangle('fill', 100, y, 50, 50, 5, 5)
      
      --birdLetter
      love.graphics.setColor(.15, .15, .15)
      love.graphics.setFont(mainFont)
      love.graphics.print(string.upper(birdLetter), 112, y-5)
      
      --pipes
      
      --blocks
      love.graphics.setColor(0,.5,0)
      love.graphics.rectangle('fill', pipeX, pipeY, pipeWidth, pipeWidth, 5, 5)
      love.graphics.rectangle('fill', pipeX, pipeY+pipeWidth, pipeWidth, pipeWidth, 5, 5)
      love.graphics.rectangle('fill', pipeX, pipeY+4*pipeWidth, pipeWidth, pipeWidth, 5, 5)
      love.graphics.rectangle('fill', pipeX, pipeY+5*pipeWidth, pipeWidth, pipeWidth, 5, 5)
      
      --letters
      love.graphics.setColor(.9,.9,.9)
      love.graphics.print(string.upper(letter1), pipeX+12, pipeY-5)
      love.graphics.print(string.upper(letter2), pipeX+12, pipeY+pipeWidth-5)
      love.graphics.print(string.upper(letter4), pipeX+12, pipeY+(4*pipeWidth)-5)
      love.graphics.print(string.upper(letter5), pipeX+12, pipeY+(5*pipeWidth)-5)
      
      --ends
      love.graphics.setColor(.6, .6, .6)
      love.graphics.rectangle('fill', pipeX, 0, pipeWidth, pipeY)
      love.graphics.rectangle('fill', pipeX, pipeY+(6*pipeWidth), pipeWidth, 600-pipeY-(6*pipeWidth))
      
      --keyboard
      love.graphics.setColor(.6,.6,.6)
      love.graphics.rectangle('fill', 0, 500, 600, 300)
      drawKeys()
    end
end

function drawKeys()
  love.graphics.setColor(1,1,1)
  love.graphics.setFont(mainFont)
  
  for i=1,#topRow do
    letter = topRow[i]
    keyY = 550
    keyX = 50*i
    love.graphics.rectangle('line', keyX, keyY, 50, 50, 5, 5)
    love.graphics.print(string.upper(letter), keyX+12, keyY-5)
  end
  
  for i=1, #midRow do
    letter = midRow[i]
    keyY = 625
    keyX = 25+50*i
    love.graphics.rectangle('line', keyX, keyY, 50, 50, 5, 5)
    love.graphics.print(string.upper(letter), keyX+12, keyY-5)
  end
  
  for i=1, #botRow do
    letter = botRow[i]
    keyY = 700
    keyX = 75+50*i
    love.graphics.rectangle('line', keyX, keyY, 50, 50, 5, 5)
    love.graphics.print(string.upper(letter), keyX+12, keyY-5)
  end
  
end

function newPipe()
  pipeX = 600
  pipeY = love.math.random(0, 200)
  if correctWord then
    newWord()
  end
  validWord = false
end

function newWord()
  if not dead then
    math.randomseed( os.time() )
    myWord = (answers[ math.random( #answers ) ])
    letter1 = (string.sub(myWord, 1, 1))
    letter2 = (string.sub(myWord, 2, 2))
    letter3 = (string.sub(myWord, 3, 3))
    letter4 = (string.sub(myWord, 4, 4))
    letter5 = (string.sub(myWord, 5, 5))
    passed = false
    prevPassed = false
    correctWord = false
    validWord = false
  end
end

function search_value (tbl, val)
    for i = 1, #tbl do
        if tbl[i] == val then
            return true
        end
    end
    return false
end

function checkWord()
  if letter3 == birdLetter and not dead then 
    correctWord = true
    --print("correct word! gain 1 point")
    score = score + 1
  else 
    word = letter1..letter2..birdLetter..letter4..letter5
    if search_value (words, word) and not dead then
      correctWord = false
      validWord = true
      --print("incorrect word, try again")
    elseif not dead then
      correctWord = false
      validWord = false
      youLose()
      --print("invalid word. you lose.")
    end
  end
end

function collision(birdX, birdY, birdWidth, pipeX, pipeY, pipeWidth, pipeSpaceHeight)
  --birdX = 100
  --birdY = y
  --birdWidth = birdHeight = 50
  --pipeWidth = 50
  --pipeSpaceHeight = 100
  birdHeight = birdWidth
  buffer = -5
  
    if
    -- Left edge of bird is to the left of the right edge of pipe
    birdX < (pipeX + pipeWidth) + buffer
    and
     -- Right edge of bird is to the right of the left edge of pipe
    (birdX + birdWidth) + buffer > pipeX
    and (
        -- Top edge of bird is above the bottom edge of first pipe segment
        birdY < pipeY + buffer
        or
        -- Bottom edge of bird is below the top edge of second pipe segment
        (birdY + birdHeight) + buffer > (pipeY + pipeSpaceHeight)
    ) then
        return true
    else
      return false
    end
    
  end
    
function youLose()
  --print("you lose")
  dead = true
  --await key press
  --love.load()
end

