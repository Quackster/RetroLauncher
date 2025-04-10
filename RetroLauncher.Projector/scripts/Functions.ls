-- Parses the INI file format
on parseIniFile txt
  tParentValues = [:]
  tChildValues = [:]
  
  tDelim = the itemDelimiter
  the itemDelimiter = "="
  
  i = 1
  
  repeat while i <= txt.count(#line)
    s = txt.getProp(#line, i)
    
    if s contains "[" then
      s = replaceChunks(s, "[", "")
      s = replaceChunks(s, "]", "")
      s = replaceChunks(s, " ", "")
      
      tKeySymbol = symbol(s)
      tParentValues.addProp(tKeySymbol, [:])
      tChildValues = tParentValues.getProp(tKeySymbol)
    else
      if txt <> ";" then
        if txt = "" then
          nothing()
        else
          if txt.getPropRef(#line, i).count(#item) = 2 then
            tKey = string(txt.getPropRef(#line, i).getProp(#item, 1))
            tValue = string(txt.getPropRef(#line, i).getProp(#item, 2))
            
            -- value(tValue)
            tChildValues.addProp(symbol(tKey), string(tValue))
          end if
        end if
      end if
    end if
    
    i = 1 + i
  end repeat
  
  the itemDelimiter = tDelim
  return(tParentValues)
end

on split str, delim
  props = []
  copyStr = str
  
  repeat while (length(copyStr) > 0) and (offset(delim, copyStr) > 0)
    numOffset = offset(delim, copyStr)
    nextChar = copyStr.char[1..length(delim)]
    
    if (nextChar = delim) then
      props.add("")
    else
      prop = copyStr.char[1..numOffset - 1]
      props.add(prop)
    end if
    
    copyStr = copyStr.char[(numOffset + length(delim))..length(copyStr)]
  end repeat
  
  if (length(copyStr) > 0) and (offset(delim, copyStr) = 0) then
    props.add(copyStr)
  end if
  
  return props
end

-- URL encode strings
on urlEncode tString
  tStr = ""
  
  i = 1
  
  repeat while i <= tString.count(#char)
    tChar = string(tString.getProp(#char, i))
    
    if ((tChar = "!") or (tChar = "*") or (tChar = "'") or (tChar = "(") or (tChar = ")") or (tChar = ";") or (tChar = ":") or (tChar = "@") or (tChar = "&") or (tChar = "=") or (tChar = "+") or (tChar = "$") or (tChar = ",") or (tChar = "/") or (tChar = "?") or (tChar = "#") or (tChar = "[") or (tChar = "]")) then
      if not integer(tChar) then
        --alert(tChar && charToNum(string(tChar)) && decTohex(charToNum(string(tChar))))
        tStr = tStr & "%" & string(decTohex(charToNum(tChar)))
      else
        tStr = tStr & tChar
      end if
    else
      tStr = tStr & tChar
    end if
    
    i = i + 1
  end repeat
  return(tStr)
end

on obfuscate tStr 
  tResult = ""
  i = 1
  repeat while i <= tStr.length
    tNumber = charToNum(tStr.getProp(#char, i))
    tNewNumber1 = (bitAnd(tNumber, 15) * 2)
    tNewNumber2 = (bitAnd(tNumber, 240) / 8)
    tRandom = (random(6) + 1)
    tNewNumber1 = ((tNewNumber1 + (bitAnd(tRandom, 6) * 16)) + bitAnd(tRandom, 1))
    tRandom = (random(6) + 1)
    tNewNumber2 = ((tNewNumber2 + (bitAnd(tRandom, 6) * 16)) + bitAnd(tRandom, 1))
    tResult = tResult & numToChar(tNewNumber2) & numToChar(tNewNumber1)
    i = (1 + i)
  end repeat
  return(tResult)
end

on deobfuscate tStr 
  tResult = ""
  i = 1
  repeat while i <= tStr.length
    if i >= tStr.length then
    else
      tRawNumbers = [charToNum(tStr.getProp(#char, (i + 1))), charToNum(tStr.getProp(#char, i))]
      tNumbers = [(bitAnd(tRawNumbers.getAt(1), 30) / 2), (bitAnd(tRawNumbers.getAt(2), 30) * 8)]
      tNumber = bitOr(tNumbers.getAt(1), tNumbers.getAt(2))
      tResult = tResult & numToChar(tNumber)
      i = (i + 1)
      i = (1 + i)
    end if
  end repeat
  return(tResult)
end


-- Replaces ocurrances of a string inside a given string with a different specified string
on replaceChunks input, stringToFind, stringToInsert
  output = ""
  findLen = stringToFind.length - 1
  repeat while input contains stringToFind
    currOffset = offset(stringToFind, input)
    output = output & input.char [1..currOffset]
    delete the last char of output
    output = output & stringToInsert
    delete input.char [1.. (currOffset + findLen)] 
  end repeat
  set output = output & input
  return output
end

-- snagged (mod'ed a bit) from mediamacros 
on hexToDec hexNum
  hexdigits = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"]
  numstring = 0
  cnt = hexNum.length
  
  repeat with x = 1 to cnt
    numString = numString * 16
    numString = numString + hexDigits.getOne(hexNum.char[x]) - 1
  end repeat
  return(numString)
end 

on decToHex input
  hexdigits = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"]
  done = false
  output = ""
  
  repeat while not done
    remainder = (input mod 16) + 1
    put hexdigits[remainder] before output
    
    if input < 16 then
      exit repeat
    else
      input = input / 16
    end if
  end repeat
  return(output)
end

on getNetData tUrl
  put ("Opening web page: " & tUrl)
  return getNetText(tUrl)
end


