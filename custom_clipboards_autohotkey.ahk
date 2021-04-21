;Alpha version!
;Author: CatoMinor - Twitter: catominor3



#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


#Persistent
OnClipboardChange("ClipChanged")
; SubMenu-Favorite
global MenuItems := []


Menu, MyMenu, Add, &Quick input, MenuHandler
Menu, MyMenu, Add

Loop, Read, custom_clipboards_list.txt
{
  Content := A_LoopReadLine
	MenuItems[A_LoopReadLine] := "no"
  ;ThisItem := A_Index . " - " . Content
  ThisItem := A_Index . " - " . Content

  k := Content
  Menu, % k, Add, Select, MenuHandler
  Menu, % k, Add
  Menu, % k, Add, Paste, MenuHandler
  Menu, % k, Add, Clear, MenuHandler
  Menu, % k, Add, View, MenuHandler
  Menu, % k, Add, Manual input, MenuHandler
  Menu, % k, Add, Open in notepad, MenuHandler

	Menu, MyMenu, Add, % ThisItem, :%k%
}
Menu, MyMenu, Add
Menu, MyMenu, Add, Clear all, MenuHandler
Menu, MyMenu, Add
Menu, MyMenu, Add, Deselect all, MenuHandler
Menu, MyMenu, Add, Backup all, MenuHandler
Return

MenuHandler:
 ;MsgBox, %A_ThisMenuItemPos%
 ;MsgBox, %A_ThisMenu%
 ;MsgBox, %A_ThisMenuItem%
  If (A_ThisMenuItem = "Select") {
    Menu, % A_ThisMenu, ToggleCheck, % A_ThisMenuItem
  

    
    If (MenuItems[A_ThisMenu] = "no") {
    
      MenuItems[A_ThisMenu] := "yes"
    } else {
      MenuItems[A_ThisMenu] := "no"
    }
  }

If (A_ThisMenuItem = "&Quick input") {
      quickInput()
  }

  If (A_ThisMenuItem = "Paste") {
      pasteFile(A_ThisMenu)
  }
   If (A_ThisMenuItem = "Clear") {
      clearFile(A_ThisMenu)
  }
   If (A_ThisMenuItem = "View") {
      viewFile(A_ThisMenu)
  }
   If (A_ThisMenuItem = "Manual input") {
      manualInput(A_ThisMenu)
  }

  If (A_ThisMenuItem = "Open in notepad") {
      openInNotepad(A_ThisMenu)
  }
  If (A_ThisMenuItem = "Clear all") {
      clearAll()
  }
   If (A_ThisMenuItem = "Backup all") {
      backupAll()
  }
   If (A_ThisMenuItem = "Deselect all") {
      deselectAll()
  }
Return


ClipChanged(type){ ;Clipboard function
  For key, value in MenuItems
    If (value = "yes") {
      updateFile(key)
    }
  Return
}


Control & RButton Up::
Sleep, 50 ; give the default context menu an oppotunity to show up
Send {CTRLDOWN}{ALTDOWN}{ALTUP}{CTRLUP} ; should close the default context menu if it exists
Menu, MyMenu, Show  ; i.e. press the Win-Z hotkey to show the menu.
return

updateFile(selectedMenu){
		stringToSave := Clipboard . "`n`n"
    fileName := selectedMenu . ".txt"
    path := "clipboards\" . fileName
		FileEncoding, UTF-8
		FileAppend, %stringToSave%, %path%
		ToolTip Text saved into %path%
		Sleep 1000
		ToolTip  ; Turn off the tip.
	  return
}

clearFile(selectedMenu){
    fileName := selectedMenu . ".txt"
    path := "clipboards\" . fileName
		FileEncoding, UTF-8
		FileDelete, %path%
		ToolTip %selectedMenu% was cleared
		Sleep 1000
		ToolTip  ; Turn off the tip.
	  return
}
pasteFile(selectedMenu){
    fileName := selectedMenu . ".txt"
    path := "clipboards\" . fileName
		FileEncoding, UTF-8
    FileRead, content, %path%
    sendFromClipboard(content)
    sleep, 100
    ToolTip %selectedMenu% was pasted
    Sleep 1000
    ToolTip  ; Turn off the tip.
    return
}
viewFile(selectedMenu){
    fileName := selectedMenu . ".txt"
    path := "clipboards\" . fileName
		FileEncoding, UTF-8
    FileRead, content, %path%
    MsgBox, %content%
    return
}

manualInput(selectedMenu){
    InputBox, inputText , Manual input, Insert the text, , 400, 100
    
    stringToSave := inputText . "`n`n"
    fileName := selectedMenu . ".txt"
    path := "clipboards\" . fileName
		FileEncoding, UTF-8
		FileAppend, %stringToSave%, %path%
		ToolTip Text saved into %path%
		Sleep 1000
		ToolTip  ; Turn off the tip.
	  return

}

openInNotepad(selectedMenu){
    fileName := selectedMenu . ".txt"
    path := "clipboards\" . fileName
		FileEncoding, UTF-8
    Run, notepad %path%
   
    return
}

clearAll(){
 for key, value in MenuItems {
   clearFile(key)
 }
}

deselectAll(){
 for key, value in MenuItems {
   MenuItems[key] := "no"
   Menu, % key, UnCheck, Select
 }
}

quickInput(){
 InputBox, inputText , Manual input, Insert the text, , 400, 100
 
 for key, value in MenuItems {
   If (value = "yes") {
    
    stringToSave := inputText . "`n`n"
    fileName := key . ".txt"
    path := "clipboards\" . fileName
		FileEncoding, UTF-8
		FileAppend, %stringToSave%, %path%
		ToolTip Text saved into %path%
		Sleep 1000
		ToolTip  ; Turn off the tip.

    }
   
 }
}




backupAll(){
    MsgBox, Copy
   pathSource := "clipboards\*.txt" 
   pathBackup := "clipboards\backup\*.*" 
   FileCopy, %pathSource% , %pathBackup%, 1
}
sendFromClipboard(textToSend){
	oldClipboard := ClipboardAll
	sleep, 70
	Clipboard := textToSend
	sleep, 70
	Send, ^v
	Sleep, 70
	Clipboard := oldClipboard
	return
}
