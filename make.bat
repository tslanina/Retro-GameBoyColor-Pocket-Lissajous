rgbasm -opocketl.obj pocketl.s
rgblink -mpocketl.map -npocketl.sym -opocketl.gb pocketl.obj
rgbfix -v -p0 pocketl.gb