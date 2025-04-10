on exitFrame me
  global gNetID, gProjectorAttributes
  
  if (gProjectorAttributes.pIsSsoLogin = FALSE) or (netDone(gNetID) and netError(gNetID) = "OK") then
    tResponseData = ""
    
    if (gProjectorAttributes.pIsSsoLogin = TRUE) then
      tResponseData = netTextResult()
    end if
    
    tSsoTicket = replaceChunks(tResponseData, "ERROR", "")
    
    if tResponseData contains "ERROR" then
      alert(tSsoTicket)
    else
      --preloadMovie("browser.dcr")
      --set browserMIAW to new(window(), "browser.dcr")
      set javaScriptProxyScriptText to the text of member("javaScriptProxyScript")
      
      setTheRunMode("AuthorPlugin") -- Bypass checks to see if it's running in browser
      forceTheExitLock(0)           -- Allow exiting from the program 
      
      setExternalParam("sw1", "site.url=" & gProjectorAttributes.pSitePath & ";url.prefix=" & gProjectorAttributes.pSitePath)
      setExternalParam("sw2", "connection.info.host=" & gProjectorAttributes.pGameIp & ";connection.info.port=" & gProjectorAttributes.pGamePort)
      setExternalParam("sw3", "client.reload.url=" & gProjectorAttributes.pSitePath)
      setExternalParam("sw4", "connection.mus.host=" & gProjectorAttributes.pMusIp & ";connection.mus.port=" & gProjectorAttributes.pMusPort)
      setExternalParam("sw5", "external.variables.txt=" & gProjectorAttributes.pExternalVariables & ";external.texts.txt=" & gProjectorAttributes.pExternalTexts)
      
      if (gProjectorAttributes.pIsSsoLogin) then
        setExternalParam("sw6", "use.sso.ticket=1;sso.ticket=" & tSsoTicket)
        
      else
        setExternalParam("sw6", "use.sso.ticket=0;sso.ticket=")
      end if
      
      go(1, gProjectorAttributes.pMovie)
      
      set javaScriptProxy to _movie.newMember(#script)
      
      if the ilk of javaScriptProxy = #member then
        if the type of javaScriptProxy = #script then
          set the name of javaScriptProxy to "JavaScript Proxy"
          set the scriptText of javaScriptProxy to javaScriptProxyScriptText
          set the scriptType of javaScriptProxy to #parent
          move(javaScriptProxy, member 82 of castLib 2)
        end if
      end if
    end if
  else 
    go(the frame)
  end if
end

on parseTextResponse tResponse
  put ("Received response: " & tResponse)
  return tResponse
end


-- CF adds some weird appending shit at the start
--on parseTextResponse tResponse
--  tResponseData = split(tResponse, "0|")
--  return tResponseData.getAt(2)
--end
