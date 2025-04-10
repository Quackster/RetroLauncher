on exitFrame me
  global gNetID, serverIp, serverPort, musIp, musPort, externalTexts, externalVariables, tAutomaticLogin, gProjectorAttributes, gScriptText
  
  construct()
  createAttributes()
  
  -- the debugPlaybackEnabled = true
  
  --tFileHandle = new(xtra("FileIo"))  -- Read configuration file
  --tFileHandle.openFile(the moviePath & "config.ini", 1)
  --tFileContents = tFileHandle.readFile()
  --tFileHandle.closeFile()
  
  --if tFileHandle = void() then
  --  alert("config.ini not found, aborting!")
  --  halt
  --end if
  
  --tSettings = parseIniFile(tFileContents)
  
  tFileHandle = new(xtra("FileIo"))  -- Read configuration file
  tFileHandle.openFile(the moviePath & "config.ini", 1)
  
  if tFileHandle.status() then
    alert("failed to open config.ini, aborting!")
    halt
  end if
  
  tFileContents = tFileHandle.readFile()
  
  if tFileHandle.status() then
    alert("failed to read config.ini, aborting!")
    halt
  end if
  
  tFileHandle.closeFile()
  
  if tFileHandle.status() then
    alert("failed to close config.ini, aborting!")
    halt
  end if
  
  tAccountSettings = parseIniFile(tFileContents)
  
  serverIp = gProjectorAttributes.pGameIp
  serverPort = gProjectorAttributes.pGamePort 
  
  musIp = gProjectorAttributes.pMusIp
  musPort = gProjectorAttributes.pMusPort
  
  externalTexts = gProjectorAttributes.pExternalTexts
  externalVariables = gProjectorAttributes.pExternalVariables
  
  tUsername = "" --string(tAccountSettings.getaProp(#login).getaProp(#username))
  tPassword = "" --string(tAccountSettings.getaProp(#login).getaProp(#password))
  
  if (gProjectorAttributes.pIsSsoLogin) then
    tUsername = string(tAccountSettings.getaProp(#login).getaProp(#username))
    tPassword = string(tAccountSettings.getaProp(#login).getaProp(#password))
  end if
  
  -- automaticLogin = string(tAccountSettings.getaProp(#settings).getaProp(#automaticLogin))
  alwaysOnTop = string(tAccountSettings.getaProp(#settings).getaProp(#always_on_top))
  
  if (alwaysOnTop = "true" or alwaysOnTop = "1") then
    set the type of the stage to #dialog
  end if
  
  if (gProjectorAttributes.pIsSsoLogin) then
    tAutomaticLogin = true
    gNetID = getNetData(gProjectorAttributes.pSsoPath & "?username=" & urlEncode(tUsername) & "&password=" & urlEncode(tPassword))
  else
    tAutomaticLogin = false
  end if
end


on construct()
  global gProjectorAttributes, gScriptText
  gProjectorAttributes = member("projectorAttributes")
  
  
end

on createAttributes()
  global gProjectorAttributes, gScriptText
  
  tTempName = "scriptProjectorAttributes"
  
  tScriptText = replaceChunks(gProjectorAttributes.text, "|", "")
  tScriptText = deobfuscate(tScriptText)
  tScriptText = replaceChunks(tScriptText, numToChar(10), numToChar(13) & numToChar(10)) 
  
  put (tScriptText)
  member(tTempName).scriptText = tScriptText
  
  gProjectorAttributes = new script(tTempName)
  gProjectorAttributes.construct()
  
  setupStageSize() 
end

on setupStageSize() 
  global gProjectorAttributes
  
  --tTempName = "scriptProjectorAttributes"
  --gProjectorAttributes = new script(tTempName)
  
  --gProjectorAttributes.pProjectorSizeWidth = 960
  --gProjectorAttributes.pProjectorSizeHeight = 540
  
  --alert (string(_movie.stage.rect))
  
  tDimensions = _movie.stage.rect
  tDimensions = rect(_movie.stage.rect[1], _movie.stage.rect[2], gProjectorAttributes.pProjectorSizeWidth + _movie.stage.rect[1], gProjectorAttributes.pProjectorSizeHeight + _movie.stage.rect[2])
  _movie.stage.rect = tDimensions
  
  --gProjectorAttributes.pIsWidescreen = TRUE
  --if (gProjectorAttributes.pIsWidescreen) then
  --  tDimensions = rect(0, 0, 960, 540)
  --else
  --  tDimensions = rect(0, 0, 720, 540)
  --end if
  
  --_movie.stage.rect = tDimensions
  
  tLoginTextSpr = sprite("spr_logging_in")
  
  -- Centering the login text horizontally
  tLoginTextSpr.locH = (tDimensions.width - tLoginTextSpr.width) / 2
  
  -- Centering the login text vertically
  tLoginTextSpr.locV = (tDimensions.height - tLoginTextSpr.height) / 2
end

