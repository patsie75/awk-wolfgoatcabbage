#!/usr/bin/gawk -f

function draw(   hold, ship, here, there) {
  hold = cargo ? toupper(substr(cargo,1,1)) : "_"
  ship = boat ? (cargo?"\\_"hold"|":"|__/") : (cargo?"|_"hold"/":"\\__|")

  here = sprintf("%c%c%c",
   wolf?" ":(hold=="W")?" ":"W",
   goat?" ":(hold=="G")?" ":"G",
   cabbage?" ":(hold=="C")?" ":"C")

  there = sprintf("%c%c%c",
   wolf?(hold=="W")?" ":"W":" ",
   goat?(hold=="G")?" ":"G":" ",
   cabbage?(hold=="C")?" ":"C":" ")

  printf(" %s |~%s~~~%s~| %s \n\n",
   here,
   boat?"~~~~":ship,
   boat?ship:"~~~~",
   there)
}

function failcheck() {
  if ((wolf == goat) && (boat != wolf)) {
    printf("The wolf eats the goat while you are on the other shore\n")
    return(1)
  }
  if ((goat == cabbage) && (boat != goat)) {
    printf("The goat eats the cabbage while you are on the other shore\n")
    return(1)
  }
  return 0
}

BEGIN {
  cargo=""
  wolf=goat=cabbage=boat=0

  ## check if SYMTAB is available
  if (!isarray(SYMTAB)) {
    printf("This game requires awk with SYMTAB (i.e. gawk >= 4.1)\n")
    exit 1
  }

  draw()
  printf("Input (? or \"help\" for help): ")

  while (getline > 0) {
    switch($1) {
      # show help
      case "?":
      case "help":
        printf("The objective of the game is to get all objects (the wolf, the goat and\n")
        printf("the cabbage) safely to the other shore. If you leave the wolf and the goat\n")
        printf("alone together, the wolf will eat the goat. If you leave the goat with the\n")
        printf("cabbage, it will happily chew on it. So think carefully how you will transport\n")
        printf("each object, one by one, across to the other shore\n")
        printf("Type \"help\" to read this help again\n")
        printf("Type \"wolf\", \"goat\" or \"cabbage\" to load or onload them\n")
        printf("Type \"go\" to travel to the other side\n")
        printf("Type \"stop\" to stop the game\n")
      break

      # quit game
      case "stop":
      case "quit":
      case "exit":
        printf("\nGive up already? You are almost there\n")
        exit 1

      # load or unload cargo
      case "wolf":
      case "goat":
      case "cabbage":
        if (cargo == "") {
          if (SYMTAB[$1] == boat) {
            cargo=$1
            printf("You put the %s in the boat\n", cargo)
          } else printf("The %s is not on this shore\n", $1)
        } else {
          if (cargo == $1) {
            printf("You remove the %s from the boat\n", cargo)
            cargo=""
          } else printf("There is already a %s in the boat\n", cargo)
        }
        draw()
      break
 
      # travel to the other side and unload possible cargo
      case "go":
        if (cargo != "") {
          printf("You go %s and remove the %s from your boat\n", boat?"back again":"to the other shore", cargo)
          SYMTAB[cargo]=SYMTAB[cargo]?0:1
          cargo = ""
        } else printf("You go empty-handed %s\n", boat?"back again":"to the other shore")

        boat=boat?0:1
  
        printf("The boat is %s, the wolf is %s, the goat is %s and the cabbage is %s\n", boat?"there":"here", wolf?"there":"here", goat?"there":"here", cabbage?"there":"here");
        draw()
      break

      # what do you mean?!
      default:
        printf("\"%s\" is not a valid option\n", $1)
    }
 
    ## winning situation 
    if (wolf && goat && cabbage && boat) {
      printf("Everybody is on the other shore. Well done!\n")
      exit 0
    }

    ## fail :(
    if (failcheck()) {
      printf("This is not a favourable situation...\n")
      exit 1
    }

    printf("Input: ")
  }

  printf("\nGive up already? You are almost there!\n")
}

