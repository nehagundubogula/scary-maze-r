

library(shiny)
library(shinyjs)

ui <- fluidPage(
  useShinyjs(),
  tags$head(
    tags$style(HTML("
      #gameArea {
        position: relative;
        width: 400px;
        height: 400px;
        background-color: white;
        border: 2px solid black;
        overflow: hidden;
      }
      #player {
        position: absolute;
        width: 10px;
        height: 10px;
        background-color: blue;
        z-index: 10;
      }
      .wall {
        position: absolute;
        background-color: red;
        z-index: 1;
      }
      #goal {
        position: absolute;
        width: 20px;
        height: 20px;
        background-color: green;
        z-index: 1;
      }
      #scareImage {
        display: none;
        position: fixed;
        top: 0; left: 0;
        width: 100vw; height: 100vh;
        background-image: url('https://preview.redd.it/7mpkx1nqd3g51.jpg?width=640&crop=smart&auto=webp&s=1b0eebf75e50c983e0511917e0b897e280b02e9b');
        background-color: black;
        background-repeat: no-repeat;
        background-position: center center;
        background-size: contain;
        z-index: 9999;
      }
    ")),
    tags$script(HTML("
      let posX = 10, posY = 10;
      let scarePlayed = false;
      window.currentRound = 1;

      function checkCollision(x, y) {
        const player = document.getElementById('player');
        player.style.left = x + 'px';
        player.style.top = y + 'px';
        const playerBox = player.getBoundingClientRect();

        const walls = document.getElementsByClassName('wall');
        for (let wall of walls) {
          const wallBox = wall.getBoundingClientRect();
          if (!(playerBox.right < wallBox.left || playerBox.left > wallBox.right ||
                playerBox.bottom < wallBox.top || playerBox.top > wallBox.bottom)) {
            Shiny.setInputValue('hitWall', Math.random());
            return false;
          }
        }

        const goal = document.getElementById('goal');
        const goalBox = goal.getBoundingClientRect();
        const overlap = !(playerBox.right < goalBox.left || playerBox.left > goalBox.right ||
                          playerBox.bottom < goalBox.top || playerBox.top > goalBox.bottom);
        const nearGoal = Math.abs(playerBox.left - goalBox.left) < 20 &&
                         Math.abs(playerBox.top - goalBox.top) < 20;

        if (!scarePlayed && window.currentRound === 3 && nearGoal) {
          scarePlayed = true;
          document.getElementById('scareImage').style.display = 'block';
          new Audio('https://files.catbox.moe/7m5djz.mp3').play();
          setTimeout(() => {
            document.getElementById('scareImage').style.display = 'none';
            Shiny.setInputValue('goalReached', Math.random());
          }, 2000);
          return false;
        }

        if (overlap && window.currentRound !== 3) {
          Shiny.setInputValue('goalReached', Math.random());
        }

        return true;
      }

      document.addEventListener('keydown', function(e) {
        let newX = posX, newY = posY;
        const step = 5;
        if (e.key === 'ArrowUp') newY -= step;
        if (e.key === 'ArrowDown') newY += step;
        if (e.key === 'ArrowLeft') newX -= step;
        if (e.key === 'ArrowRight') newX += step;
        if (newX < 0 || newY < 0 || newX > 385 || newY > 385) return;
        if (checkCollision(newX, newY)) {
          posX = newX;
          posY = newY;
        }
      });

      Shiny.addCustomMessageHandler('resetPlayer', function(message) {
        posX = message.x || 10;
        posY = message.y || 10;
        const player = document.getElementById('player');
        player.style.left = posX + 'px';
        player.style.top = posY + 'px';
      });

      Shiny.addCustomMessageHandler('updateRound', function(message) {
        window.currentRound = message.round;
        if (window.currentRound !== 3) {
          scarePlayed = false;
        }
      });
    "))
  ),
  h2("Scary Maze Game — Arrow Key Version"),
  div(id = "gameArea",
      div(id = "player", style = "left:10px; top:10px;"),
      uiOutput("mazeLayout")
  ),
  div(id = "scareImage"),
  verbatimTextOutput("status")
)

server <- function(input, output, session) {
  round <- reactiveVal(1)
  
  output$mazeLayout <- renderUI({
    if (round() == 1) {
      tagList(
        div(class = "wall", style = "left:0px; top:40px; width:350px; height:10px;"),
        div(class = "wall", style = "left:0px; top:390px; width:400px; height:10px;"),
        div(class = "wall", style = "left:100px; top:330px; width:250px; height:10px;"),
        div(class = "wall", style = "left:0px; top:200px; width:110px; height:10px;"),
        div(class = "wall", style = "left:340px; top:40px; width:10px; height:290px;"),
        div(class = "wall", style = "left:390px; top:40px; width:10px; height:360px;"),
        div(class = "wall", style = "left:100px; top:200px; width:10px; height:130px;"),
        div(class = "wall", style = "left:0px; top:200px; width:10px; height:200px;"),
        div(id = "goal", style = "left:40px; top:250px;")
      )
    } else if (round() == 2) {
      tagList(
        div(class = "wall", style = "left:30px; top:70px; width:320px; height:10px;"),
        div(class = "wall", style = "left:30px; top:360px; width:260px; height:10px;"),
        div(class = "wall", style = "left:120px; top:180px; width:170px; height:10px;"),
        div(class = "wall", style = "left:120px; top:100px; width:180px; height:10px;"),
        div(class = "wall", style = "left:150px; top:240px; width:90px; height:10px;"),
        div(class = "wall", style = "left:150px; top:300px; width:90px; height:10px;"),
        div(class = "wall", style = "left:100px; top:210px; width:90px; height:8px;"),
        div(class = "wall", style = "left:100px; top:330px; width:90px; height:8px;"),
        div(class = "wall", style = "left:30px; top:70px; width:10px; height:300px;"),
        div(class = "wall", style = "left:280px; top:180px; width:10px; height:190px;"),
        div(class = "wall", style = "left:120px; top:100px; width:10px; height:80px;"),
        div(class = "wall", style = "left:230px; top:240px; width:10px; height:60px;"),
        div(class = "wall", style = "left:100px; top:210px; width:10px; height:120px;"),
        div(id = "goal", style = "left:180px; top:265px;")
      )
    } else if (round() == 3) {
      tagList(
        div(class = "wall", style = "left:0px; top:0px; width:400px; height:10px;"),
        div(class = "wall", style = "left:0px; top:390px; width:400px; height:10px;"),
        div(class = "wall", style = "left:0px; top:0px; width:10px; height:400px;"),
        div(class = "wall", style = "left:390px; top:0px; width:10px; height:400px;"),
        div(class = "wall", style = "left:100px; top:205px; width:100px; height:95px;"),
        div(class = "wall", style = "left:10px; top:60px; width:360px; height:8px;"),
        div(class = "wall", style = "left:30px; top:120px; width:300px; height:8px;"),
        div(class = "wall", style = "left:70px; top:180px; width:320px; height:8px;"),
        div(class = "wall", style = "left:65px; top:300px; width:300px; height:8px;"),
        div(class = "wall", style = "left:270px; top:325px; width:160px; height:8px;"),
        div(class = "wall", style = "left:360px; top:68px; width:8px; height:75px;"),
        div(class = "wall", style = "left:30px; top:120px; width:8px; height:250px;"),
        div(class = "wall", style = "left:320px; top:128px; width:8px; height:52px;"),
        div(class = "wall", style = "left:70px; top:188px; width:8px; height:30px;"),
        div(class = "wall", style = "left:390px; top:188px; width:8px; height:70px;"),
        div(class = "wall", style = "left:70px; top:248px; width:8px; height:52px;"),
        div(class = "wall", style = "left:300px; top:230px; width:8px; height:70px;"),
        div(class = "wall", style = "left:240px; top:180px; width:8px; height:80px;"),
        div(class = "wall", style = "left:200px; top:300px; width:8px; height:100px;"),
        div(id = "goal", style = "left:340px; top:350px;")
      )
    }
  })
  
  output$status <- renderText({
    paste("Round:", round())
  })
  
  observeEvent(input$hitWall, {
    showModal(modalDialog("💥 Don't touch the wall. Restarting...", easyClose = TRUE))
    round(1)
    session$sendCustomMessage("updateRound", list(round = 1))
    session$sendCustomMessage("resetPlayer", list(x = 10, y = 10))
  })
  
  observeEvent(input$goalReached, {
    if (round() == 1) {
      round(2)
      session$sendCustomMessage("updateRound", list(round = 2))
      session$sendCustomMessage("resetPlayer", list(x = 10, y = 10))
    } else if (round() == 2) {
      round(3)
      session$sendCustomMessage("updateRound", list(round = 3))
      session$sendCustomMessage("resetPlayer", list(x = 30, y = 30))
    } else {
      showModal(modalDialog("🎉 YOU WIN... but at what cost?", easyClose = TRUE))
      round(1)
      session$sendCustomMessage("updateRound", list(round = 1))
      session$sendCustomMessage("resetPlayer", list(x = 10, y = 10))
    }
  })
}

shinyApp(ui, server)