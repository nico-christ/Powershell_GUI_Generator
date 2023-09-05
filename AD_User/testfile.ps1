Import-Module ActiveDirectory

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$countryList = Import-Csv -Delimiter "," -Path C:\Scripts\user_reg\Data\country.csv

<#------------------------------ functions------------------------------------
these are in the "gui_test.ps1"
#>
function Create-Form {
    param (
        [Parameter(Mandatory=$true)]
        [String]$Title,

        [Parameter(Mandatory=$true)]
        [string]$Name,

        [Parameter()]
        [int]$Width,

        [Parameter()]
        [int]$Height,

        [Parameter(Mandatory=$true)]
        [String]$StartPosition
    )

    if ($Name -eq $null) {
        throw "Form must have a Name"
    }
    elseif ($Title -eq $null) {
        throw "The Form needs a Title."
    }
    
    # Create the form
    $Form = New-Object System.Windows.Forms.Form
    $Form.Text = $Title
    $Form.Name = $Name
    $Form.StartPosition = $StartPosition

    #adds the width and height if given
    if ($Width) {
            # Validate Width parameter
        if ($FormWidth -le 0) {throw "Width must be greater than 0."}
        $Form.Width = $Width
    }
    if ($Height) {
        if ($FormHeight -le 0) {throw "Height must be greater than 0."}
        $Form.Height = $Height
    }

    return $Form
}

function Create-GroupBox {
    param (
        [String]$Title,

        [Parameter()]
        [int]$Width,
        [Parameter()]
        [int]$Height,

        [Parameter()]
        [int]$PosX,
        [Parameter()]
        [int]$PosY
    )

    $groupBox = New-Object System.Windows.Forms.GroupBox
    $groupBox.Text = $Title
    $groupBox.Name = "${title}_groupBox"

    #adds the width and height if given
    if ($Width) {$groupBox.Width = $Width}
    if ($Height) {$groupBox.Height = $Height}

    #adds the X-Pos and Y-Pos if given
    if ($PosX) {$groupBox.Left = $PosX}
    if ($PosY) {$groupBox.Top = $PosY}

    return $groupBox
}

function Create-Label {
    param (
        #[Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$Content,

        [Parameter()]
        [int]$Width,
        [Parameter()]
        [int]$Height,

        [Parameter()]
        [int]$PosX,
        [Parameter()]
        [int]$PosY
    )

    $label = New-Object System.Windows.Forms.Label
    $label.Name = "${Name}Label"
    $label.Text = $Content
    
    #adds the width and height if given
    if ($Width) {$label.Width = $Width}
    if ($Height) {$label.Height = $Height}

    #adds the X-Pos and Y-Pos if given
    if ($PosX) {$label.Left = $PosX}
    if ($PosY) {$label.Top = $PosY}

    return $label
}

function Create-TextBox {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [string]$Content,

        [Parameter()]
        [int]$Width,
        [Parameter()]
        [int]$Height,

        [Parameter()]
        [int]$PosX,
        [Parameter()]
        [int]$PosY
    )

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Name = "${Name}TextBox"
    $textBox.Text = $Content
    
    #adds the width and height if given
    if ($Width) {$textBox.Width = $Width}
    if ($Height) {$textBox.Height = $Height}

    #adds the X-Pos and Y-Pos if given
    if ($PosX) {$textBox.Left = $PosX}
    if ($PosY) {$textBox.Top = $PosY}

    return $textBox
}

function Create-CheckBox {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [String]$Title,

        [Parameter()]
        [int]$Width,
        [Parameter()]
        [int]$Height,

        [Parameter()]
        [int]$PosX,
        [Parameter()]
        [int]$PosY
    )

    $checkBox = New-Object System.Windows.Forms.CheckBox
    $checkBox.Name = "${Name}CheckBox"
    $checkBox.Text = $Title

    #adds the width and height if given
    if ($Width) {$checkBox.Width = $Width}
    if ($Height) {$checkBox.Height = $Height}

    #adds the X-Pos and Y-Pos if given
    if ($PosX) {$checkBox.Left = $PosX}
    if ($PosY) {$checkBox.Top = $PosY}

    return $checkBox
}

function Create-DropdownList {
    param (
        [Parameter(Mandatory = $true)]
        [String]$Name,

        [Parameter(Mandatory = $true)]
        [System.Windows.Forms.Form]$Form,

        [System.Collections.ArrayList]$List,

        [Parameter()]
        [int]$Width,
        [Parameter()]
        [int]$Height,

        [Parameter()]
        [int]$PosX,
        [Parameter()]
        [int]$PosY
    )
    
    $dropdown = New-Object System.Windows.Forms.ComboBox
    $dropdown.Name = "${Name}Dropdownlist"
    $dropdown.DataSource = $List #uses the data from the countryList
    $dropdown.DisplayMember = "Name"# Displays the country names

    #adds the width and height if given
    if ($Width) {$dropdown.Width = $Width}
    if ($Height) {$dropdown.Height = $Height}

    #adds the X-Pos and Y-Pos if given
    if ($PosX) {$dropdown.Left = $PosX}
    if ($PosY) {$dropdown.Top = $PosY}

    return $dropdown
}

function Create-Button {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ButtonName,

        [Parameter(Mandatory=$true)]
        [string]$ButtonText,

        [Parameter(Mandatory=$true)]
        [System.Windows.Forms.DockStyle]$ButtonDockStyle,

        [Parameter()]
        [int]$Width,

        [Parameter()]
        [int]$Height,

        [Parameter()]
        [int]$PosX,

        [Parameter()]
        [int]$PosY,

        # Sets the Button Dialogtype
        [Parameter()]
        [Windows.Forms.DialogResult]$DialogResult,

        [Parameter(Mandatory=$true)]
        [ScriptBlock]$ButtonAction
    )
    
    $button = New-Object System.Windows.Forms.Button
    $button.Name = $ButtonName
    $button.Text = $ButtonText

    #adds the width and height if given
    if ($Width) {$button.Width = $Width}
    if ($Height) {$button.Height = $Height}

    #adds the X-Pos and Y-Pos if given
    if ($PosX) {$button.Left = $PosX}
    if ($PosY) {$button.Top = $PosY}
    
    # Set the dock style of the button
    $button.Dock = $ButtonDockStyle

    $button.DialogResult = $DialogResult
    
    # Add the button click event handler
    $button.Add_Click($ButtonAction)
    
    return $button
}

function Get-StringFromTextBox {
    param (
        [Parameter()]
        [System.Windows.Forms.TextBox]$TextBox
    )

    $string = $TextBox.Text.Trim()
    return $string
}

function Get-BoolFromCheckBox {
    param (
        [Parameter()]
        [System.Windows.Forms.CheckBox]$CheckBox
    )

    $bool = $CheckBox.Checked
    return $bool
}

#----------------------- create form ---------------------------------------------
$form = Create-Form -Title "New AD User" -Name "ADUserGUI" -StartPosition "CenterScreen"


#------------------------- edit form -------------------------------------------------
$form.BackColor = "#ebebeb"

$GivenNameLabel = Create-Label -Content "First Name" -Width 80 -Height 20 -PosX 20 -PosY 20
$GivenNameTextBox = Create-TextBox -Name "GivenNameTextBox" -Content "Some text..." -Width 200 -Height 60 -PosX 20 -PosY 40

$form.Controls.Add($GivenNameLabel)
$form.Controls.Add($GivenNameTextBox)

#------------ control Buttons----------------------------------------
$okButton = Create-Button -ButtonName "createUserButton" -ButtonText "Create" -ButtonDockStyle ([System.Windows.Forms.DockStyle]::Bottom) -DialogResult ([Windows.Forms.DialogResult]::OK) -ButtonAction {
    # Actions to be performed when OK button is clicked
    $form.Close()
    Write-Host "OK button clicked"
}
$cancelButton = Create-Button -ButtonName "cancelUserButton" -ButtonText "Cancel" -ButtonDockStyle ([System.Windows.Forms.DockStyle]::Bottom) -DialogResult ([Windows.Forms.DialogResult]::Cancel) -ButtonAction {
    # Actions to be performed when OK button is clicked
    $form.Close()
    Write-Host "Cancel button clicked"
}

# add buttons to form
$form.Controls.Add($okButton)
$form.Controls.Add($cancelButton)

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    Get-StringFromTextBox -TextBox $GivenNameTextBox
}
elseif ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
    # Cancel button was clicked, perform necessary actions
    Write-Host "Performing actions based on Cancel button click..."
}
