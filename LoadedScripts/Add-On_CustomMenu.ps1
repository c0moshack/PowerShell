If ($PGSE) {
#$PGSE.Configuration.Colors.Console.BackgroundColor = [System.Drawing.Color]::Blue
#$PGSE.Configuration.Colors.Console.ForegroundColor = [System.Drawing.Color]::White
#$PGSE.Configuration.Colors.Console.WarningBackgroundColor = [System.Drawing.Color]::Black
#$PGSE.Configuration.Colors.Console.WarningForegroundColor = [System.Drawing.Color]::Yellow
#$PGSE.Configuration.Colors.Console.ErrorBackgroundColor   = [System.Drawing.Color]::Black
#$PGSE.Configuration.Colors.Console.ErrorForegroundColor   = [System.Drawing.Color]::Red
#$PGSE.Configuration.Colors.Console.VerboseBackgroundColor = [System.Drawing.Color]::Black
#$PGSE.Configuration.Colors.Console.VerboseForegroundColor = [System.Drawing.Color]::Yellow
#$PGSE.Configuration.Colors.Console.DebugBackgroundColor   = [System.Drawing.Color]::Black
#$PGSE.Configuration.Colors.Console.DebugForegroundColor   = [System.Drawing.Color]::Yellow
#Clear-Host
	#region Create the Name menu.

	if (-not ($NameMenu = $PGSE.Menus['MenuBar.Custom'])) {
		$NameCommand = New-Object -TypeName Quest.PowerGUI.SDK.MenuCommand -ArgumentList 'MenuBar','Custom'
		$NameCommand.Text = 'Custom'
		$PGSE.Commands.Add($NameCommand)
		$index = -1
		if ($ToolsMenu = $PGSE.Menus['MenuBar.Tools']) {
			$index = $PGSE.Menus.IndexOf($ToolsMenu)
		}
		if ($index -ge 0) {
			$PGSE.Menus.Insert($index + 1,$NameCommand)
		} else {
			$PGSE.Menus.Add($NameCommand)
		}
		$NameMenu = $PGSE.Menus['MenuBar.Custom']
	}

	#endregion

	#region Create the Name menu item in the Menu menu.

	if (($MenuMenu = $PGSE.Menus['MenuBar.Custom']) -and
	    (-not ($NameMenuItem = $MenuMenu.Items['MenuCommand.CommentBlock']))) {
		if (-not ($NameCommand = $PGSE.Commands['MenuCommand.CommentBlock'])) {
			$NameCommand = New-Object -TypeName Quest.PowerGUI.SDK.ItemCommand -ArgumentList 'MenuCommand','CommentBlock'
			$NameCommand.Text = 'Add-CommentBlock'
			#$NameCommand.Image = $imageLibrary['MyImage16']
			$NameCommand.AddShortcut('Control+Alt+C')
			$NameCommand.ScriptBlock = {
				Add-CommentBlock
			}
			$PGSE.Commands.Add($NameCommand)
		}
		$index = -1
		if ($ToolsMenuItem = $MenuMenu.Items['MenuCommand.Tools']) {
			$index = $MenuMenu.Items.IndexOf($ToolsMenuItem)
		}
		if (($index -ge 0) -and ($index -lt ($MenuMenu.Items.Count - 1))) {
			$MenuMenu.Items.Insert($index + 1,$NameCommand)
		} else {
			$MenuMenu.Items.Add($NameCommand)
		}
		if ($NameMenuItem = $MenuMenu.Items['MenuCommand.CommentBlock']) {
			$NameMenuItem.FirstInGroup = $false
		}
	}

	#endregion

	#region Create the Name menu item in the Menu menu.

	if (($MenuMenu = $PGSE.Menus['MenuBar.Custom']) -and
	    (-not ($NameMenuItem = $MenuMenu.Items['MenuCommand.AddHeader']))) {
		if (-not ($NameCommand = $PGSE.Commands['MenuCommand.AddHeader'])) {
			$NameCommand = New-Object -TypeName Quest.PowerGUI.SDK.ItemCommand -ArgumentList 'MenuCommand','AddHeader'
			$NameCommand.Text = 'Add-Header'
			#$NameCommand.Image = $imageLibrary['MyImage16']
			$NameCommand.AddShortcut('Control+Alt+T')
			$NameCommand.ScriptBlock = {
				Add-HeaderToScript
			}
			$PGSE.Commands.Add($NameCommand)
		}
		$index = -1
		if ($ToolsMenuItem = $MenuMenu.Items['MenuCommand.Tools']) {
			$index = $MenuMenu.Items.IndexOf($ToolsMenuItem)
		}
		if (($index -ge 0) -and ($index -lt ($MenuMenu.Items.Count - 1))) {
			$MenuMenu.Items.Insert($index + 1,$NameCommand)
		} else {
			$MenuMenu.Items.Add($NameCommand)
		}
		if ($NameMenuItem = $MenuMenu.Items['MenuCommand.AddHeader']) {
			$NameMenuItem.FirstInGroup = $false
		}
	}

	#endregion

	#region Create the Name menu item in the Menu menu.

	if (($MenuMenu = $PGSE.Menus['MenuBar.Custom']) -and
	    (-not ($NameMenuItem = $MenuMenu.Items['MenuCommand.AddHelp']))) {
		if (-not ($NameCommand = $PGSE.Commands['MenuCommand.AddHelp'])) {
			$NameCommand = New-Object -TypeName Quest.PowerGUI.SDK.ItemCommand -ArgumentList 'MenuCommand','AddHelp'
			$NameCommand.Text = 'Add-Help'
			#$NameCommand.Image = $imageLibrary['MyImage16']
			$NameCommand.AddShortcut('Control+Alt+H')
			$NameCommand.ScriptBlock = {
				Add-Help
			}
			$PGSE.Commands.Add($NameCommand)
		}
		$index = -1
		if ($ToolsMenuItem = $MenuMenu.Items['MenuCommand.Tools']) {
			$index = $MenuMenu.Items.IndexOf($ToolsMenuItem)
		}
		if (($index -ge 0) -and ($index -lt ($MenuMenu.Items.Count - 1))) {
			$MenuMenu.Items.Insert($index + 1,$NameCommand)
		} else {
			$MenuMenu.Items.Add($NameCommand)
		}
		if ($NameMenuItem = $MenuMenu.Items['MenuCommand.AddHelp']) {
			$NameMenuItem.FirstInGroup = $false
		}
	}

	#endregion
	
	#region Create the Name menu item in the Menu menu.

	if (($MenuMenu = $PGSE.Menus['MenuBar.Custom']) -and
	    (-not ($NameMenuItem = $MenuMenu.Items['MenuCommand.NewFunction']))) {
		if (-not ($NameCommand = $PGSE.Commands['MenuCommand.NewFunction'])) {
			$NameCommand = New-Object -TypeName Quest.PowerGUI.SDK.ItemCommand -ArgumentList 'MenuCommand','NewFunction'
			$NameCommand.Text = 'New-Function'
			#$NameCommand.Image = $imageLibrary['MyImage16']
			$NameCommand.AddShortcut('Control+Alt+F')
			$NameCommand.ScriptBlock = {
				New-Function
			}
			$PGSE.Commands.Add($NameCommand)
		}
		$index = -1
		if ($ToolsMenuItem = $MenuMenu.Items['MenuCommand.Tools']) {
			$index = $MenuMenu.Items.IndexOf($ToolsMenuItem)
		}
		if (($index -ge 0) -and ($index -lt ($MenuMenu.Items.Count - 1))) {
			$MenuMenu.Items.Insert($index + 1,$NameCommand)
		} else {
			$MenuMenu.Items.Add($NameCommand)
		}
		if ($NameMenuItem = $MenuMenu.Items['MenuCommand.NewFunction']) {
			$NameMenuItem.FirstInGroup = $false
		}
	}

	#endregion
}