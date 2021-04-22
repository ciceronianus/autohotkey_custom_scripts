;Alpha version!
;Author: CatoMinor - Twitter: catominor3

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


#Persistent
OnClipboardChange("ClipChanged")
; SubMenu-Favorite

global clipboardMonitorActive := 1
global multiselectOfClipboards := 1
global MenuItems := []


Menu, MyMenu, Add, &Quick input, MenuHandler
Menu, MyMenu, Icon, &Quick input, spark.png,, 0
Menu, MyMenu, Add

Loop, Read, custom_clipboards_list.txt
{
  Content := A_LoopReadLine
	Menu, save_to, Add, % Content, SaveToHandler
}

Menu, MyMenu, Add, Save to, :save_to
Menu, MyMenu, Icon, Save to, export-share.png,, 0
Menu, MyMenu, Add
Loop, Read, custom_clipboards_list.txt
{
  Content := A_LoopReadLine
	MenuItems[A_LoopReadLine] := "no"
  ;ThisItem := A_Index . " - " . Content
  ThisItem := Content

  k := Content
  Menu, % k, Add, &Select, MenuHandler
  Menu, % k, Add, S&ave to this, SaveToHandler
  Menu, % k, Add, &Manual input, MenuHandler

  Menu, % k, Add
  Menu, % k, Add, &Paste, MenuHandler
  Menu, % k, Add, &Clear, MenuHandler
  Menu, % k, Add, View, MenuHandler
  Menu, % k, Add, &Backup, MenuHandler
  Menu, % k, Add, &Open in notepad, MenuHandler


	Menu, MyMenu, Add, % ThisItem, :%k%
}


	

Menu, MyMenu, Add
Menu, MyMenu, Add, Edit clipboards, MenuHandler
Menu, MyMenu, Icon, Edit clipboards, edit-pen.png,, 0
Menu, MyMenu, Add, Clipboard monitor, MenuHandler
If (multiselectOfClipboards = 1) {
Menu, MyMenu, Check, Clipboard monitor
}

Menu, MyMenu, Add, Multiselect of clipboards, MenuHandler
If (multiselectOfClipboards = 1) {
Menu, MyMenu, Check, Multiselect of clipboards
}

;Menu, MyMenu, Disable, Multiselect of clipboards



Menu, MyMenu, Add
Menu, MyMenu, Add, Clear all, MenuHandler
Menu, MyMenu, Icon, Clear all, trash-can.png,, 0
Menu, MyMenu, Add
Menu, MyMenu, Add, &Deselect all, MenuHandler
Menu, MyMenu, Icon, &Deselect all, cancel.png,, 0
Menu, MyMenu, Add, &Backup all, MenuHandler
Menu, MyMenu, Icon, &Backup all, download-file.png,, 0
Return

MenuHandler:
 ;MsgBox, %A_ThisMenuItemPos%
 ;MsgBox, %A_ThisMenu%
 ;MsgBox, %A_ThisMenuItem%
  If (A_ThisMenuItem = "&Select") {
    
    If (multiselectOfClipboards = 0) {
      deselectAll()

      }
    


    Menu, % A_ThisMenu, ToggleCheck, % A_ThisMenuItem

    If (MenuItems[A_ThisMenu] = "no") {
      Menu, MyMenu, Icon, % A_ThisMenu, tick.png,, 0
      MenuItems[A_ThisMenu] := "yes"
    } else {
      MenuItems[A_ThisMenu] := "no"
      Menu, MyMenu, NoIcon, % A_ThisMenu
    }
    
  }

If (A_ThisMenuItem = "&Quick input") {
      quickInput()
  }

  If (A_ThisMenuItem = "&Paste") {
      pasteFile(A_ThisMenu)
  }
   If (A_ThisMenuItem = "&Clear") {
      clearFile(A_ThisMenu)
  }
   If (A_ThisMenuItem = "View") {
      viewFile(A_ThisMenu)
  }
   If (A_ThisMenuItem = "&Manual input") {
      manualInput(A_ThisMenu)
  }

  If (A_ThisMenuItem = "&Open in notepad") {
      openInNotepad(A_ThisMenu)
  }

  If (A_ThisMenuItem = "Backup") {
      backupFile(A_ThisMenu)
  }
  
   If (A_ThisMenuItem = "Edit clipboards") {
      RunWait, notepad custom_clipboards_list.txt 
      Reload
  }
    If (A_ThisMenuItem = "Multiselect of clipboards") {
         

        If ( multiselectOfClipboards = 0) {
          multiselectOfClipboards := 1
          Menu, MyMenu, Check, % A_ThisMenuItem

        } else {
          multiselectOfClipboards := 0
          Menu, MyMenu, UnCheck, % A_ThisMenuItem
         
        }
    
     }


       If (A_ThisMenuItem = "Clipboard monitor") {
          

        If ( clipboardMonitorActive = 0) {
          clipboardMonitorActive := 1
          Menu, MyMenu, Check, % A_ThisMenuItem

        } else {
          clipboardMonitorActive := 0
          Menu, MyMenu, UnCheck, % A_ThisMenuItem
         
        }
    
     }

 
  
  If (A_ThisMenuItem = "Clear all") {
      clearAll()
  }
   If (A_ThisMenuItem = "&Backup all") {
      backupAll()
  }
   If (A_ThisMenuItem = "&Deselect all") {
      deselectAll()
  }
Return

SaveToHandler:
    clipboardMonitorState := clipboardMonitorActive
    clipboardMonitorActive := 0
   
    If (A_ThisMenu = "save_to") {    
      Send, ^c
      updateFile(A_ThisMenuItem)
      }
    Else {
      Send, ^c
      updateFile(A_ThisMenu)

    }


  clipboardMonitorActive := clipboardMonitorState
Return  

ClipChanged(type){ ;Clipboard function
  If (clipboardMonitorActive = 1) {
    For key, value in MenuItems
      If (value = "yes") {
        updateFile(key)
      }
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

backupFile(selectedMenu) {
  pathSource := "clipboards\"  . %selectedMenu% .  "*.txt"
  pathBackup := "clipboards\backup\" . %selectedMenu% .  "*.txt"
  FileCopy, %pathSource% , %pathBackup%, 1


}

openInNotepad(selectedMenu){
    fileName := selectedMenu . ".txt"
    path := "clipboards\" . fileName
		FileEncoding, UTF-8
    RunWait, notepad %path%
    
   
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
   Menu, % key, UnCheck, &Select
   Menu, MyMenu, NoIcon, % key
 }
}

quickInput(){
 InputBox, inputText , Manual input, Insert the text, , 400, 100
 
 anyYes := 0

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
    anyYes := 1
    }
   
 }

If (anyYes = 0) {
  

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

; Quick input for anything
^!q:: quickInput()