#AppleIntelInfoLoader v1.0.0

Introduction

AppleIntelInfo Loader is a simple automated bash script that can compile and load Piker-Alpha's <a href="https://github.com/Piker-Alpha/AppleIntelInfo">AppleIntelInfo.kext</a> without any user input.

You can download the latest version of AppleIntelInfo Loader to your Desktop by entering the following command in a terminal window:
``` sh
curl -o ~/Desktop/aiiLoader.command https://raw.githubusercontent.com/mattcarlotta/AppleIntelInfoLoader/master/aiiLoader.command
```

You can then verify the downloaded size (should be 6008 Bytes):
``` sh
wc -c aiiLoader.command
```

Then, you must change the file permissions to make it executable:
``` sh
chmod +x ~/Desktop/aiiLoader.command
```

Simply double click the aiiLoader.command file to load the script or you can use this command:
``` sh
~/Desktop/aiiLoader.command
```

--------------------------------------------------------------------------------------------------------------
**Note: If at any point you wish to abort the script, simple press "ctrl+c"!
**Special Note: Huge thanks to PMHeart for refactoring my entire script and making it more flexible!
