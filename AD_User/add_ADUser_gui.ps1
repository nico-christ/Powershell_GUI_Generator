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
$form = Create-Form -Title "New AD User" -Name "ADUserGUI" -FormWidth 1000 -FormHeight 850
$form.ShowDialog()

#------------------------- edit form -------------------------------------------------
$form.BackColor = "#ebebeb"


#---------------------- create Groupboxes ----------------------------------------
$groupBoxGeneral = Create-GroupBox -Title "General" -Width 400 -Height //TODO -PosX 20 -PosY 20# GroupBox um den Allgemein Tab ein zugeben
$groupBoxAddress = Create-GroupBox -Title "Address" -Width 400 -Height //TODO -PosX //TODO -PosY //TODO# GroupBox um den Adress Tab ein zu geben
$groupBoxAccount = Create-GroupBox -Title "Account" -Width 400 -Height //TODO -PosX //TODO -PosY //TODO# GroupBox um den Konto Tab ein zu geben
$groupBoxAccountOptions = Create-GroupBox -Title "Account Options" -Width 380 -Height //TODO -PosX //TODO -PosY //TODO# GroupBox um die Konto Optionen ein zu geben
$groupBoxPassword = Create-GroupBox -Title "Password" -Width 400 -Height //TODO -PosX //TODO -PosY //TODO# GroupBox um den Passwort Tab ein zu geben
#$groupBoxMiscellaneous = Create-GroupBox -Title "Miscellaneous" # GroupBox um Verschiedenes ein zu geben
$groupBoxControls = Create-GroupBox -Width 830 -Height 30 -PosX 10 -PosY 970

#------------------------------ create tab general -----------------------------------
$form.Controls.Add($groupBoxGeneral)

$GivenNameLabel = Create-Label -Content "First Name"
$GivenNameTextBox = Create-TextBox -Name "GivenNameTextBox"

$SurnameLabel = Create-Label -Content "Surname"
$SurnameTextBox = Create-TextBox -Name "SurnameTextBox"

$InitialsLabel = Create-Label -Content "Initials"
$InitialsTextBox = Create-TextBox -Name "InitialsTextBox"

$NameLabel = Create-Label -Content "Username"
$NameTextBox = Create-TextBox -Name "NameTextBox"

$DisplayNameLabel = Create-Label -Content "Display Name"
$DisplayNameTextBox = Create-TextBox -Name "DisplayNameTextBox"

$DiscriptionLabel = Create-Label -Content "Discription"
$DiscriptionTextBox = Create-TextBox -Name "DiscriptionTextBox"

$OfficeLabel = = Create-Label -Content "Office"
$OfficeComboBox = Create-DropdownList -Name "OfficeComboBox"

$OfficePhoneLabel = = Create-Label -Content "Office Phone"
$OfficePhoneTextBox = Create-TextBox -Name "OfficePhoneTextBox"

$EmailAdressLabel = Create-Label -Content "Email"
$EmailAdressTextBox = Create-TextBox -Name "EmailAdressTextBox"

$HomepageLabel = Create-Label -Content "Website"
$HomepageTextBox = Create-TextBox -Name "HomepageTextBox"

$groupBoxGeneral.Controls.AddRange @{$GivenNameLabel, $GivenNameTextBox, $SurnameLabel, $SurnameTextBox, $DisplayNameLabel, $DisplayNameTextBox, $OfficeLabel, $OfficeComboBox, $OfficePhoneLabel, $OfficePhoneTextBox, $EmailAdressLabel, $EmailAdressTextBox, $HomepageLabel, $HomepageTextBox}


#------------------------------------ create tab address----------------------------------------------------------------------------
$form.Controls.Add($groupBoxAddress)

$StreetAddressLabel = Create-Label -Content "Street Address"
$StreetAddressTextBox = Create-TextBox -Name "StreetAddressTextBox"

$POBoxLabel = Create-Label -Content "Post Box"
$POBoxTextBox = Create-TextBox -Name "POBoxTextBox"

$CityLabel = Create-Label -Content "City"
$CityTextBox = Create-TextBox -Name "CityTextBox"

$StateLabel = Create-Label -Content "State"
$StateTextBox = Create-TextBox -Name "StateTextBox"

$PostalCodeLabel = Create-Label -Content "Postal Code"
$PostalCodeTextBox = Create-TextBox -Name "PostalCodeTextBox"

$CountryLabel = Create-Label -Content "Country"
$CountryComboBox = Create-DropdownList -Name "CountryComboBox"

$groupBoxAddress.Controls.AddRange @{$StreetAddressLabel, $StreetAddressTextBox, $POBoxLabel, $POBoxTextBox, $CityLabel, $CityTextBox, $StateLabel, $StateTextBox, $PostalCodeLabel, $PostalCodeTextBox, $CountryLabel, $CountryComboBox}



#---------------------------------- create tab account ------------------------------------------------------------------------------------
$form.Controls.Add($groupBoxAccount)
$UserPrincipal = Create-Label -Content "Login Name Domain" #username
$UserPrincipalNameTextBox = Create-TextBox -Name "UserPrincipalNameTextBox"

$groupBoxAccount.controls.AddRange @{$UserPrincipal, $UserPrincipalNameTextBox}

    #---------------------------------- create sub-tab account options ---------------------------
    $groupBoxAccount.Controls.Add($groupBoxAccountOptions)
    $ChangePasswordAtLogonBox = Create-CheckBox -Name "ChangePasswordAtLogonBox" -Title "Change Password At Logon"
    #$EnabledCheckBox = Create-CheckBox -Name
    $CannotChangePasswordCheckBox = Create-CheckBox -Name "CannotChangePasswordCheckBox" -Title "Cannot Change Password"
    $EnabledCheckBox = Create-CheckBox -Name "EnabledCheckBox" -Title "Enable Account"

    $groupBoxAccountOptions.controls.AddRange @{$ChangePasswordAtLogonBox, $CannotChangePasswordCheckBox, $EnabledCheckBox}

#passwordsection
$form.Controls.Add($groupBoxPassword)
$passwordLabel = Create-Label -Content "Password"
$passwordTextBox = Create-TextBox -Name "passwordTextBox"

$groupBoxPassword.Controls.AddRange @{$passwordLabel, $passwordTextBox}



#-------------------------------- edit properties -------------------------------------------------------



#---------------------- create and cancel buttons -----------------------------
$form.Controls.Add($groupBoxControls)
#------------ control Buttons----------------------------------------
$okButton = Create-Button -ButtonName "createUserButton" -ButtonText "Create" -ButtonDockStyle ([System.Windows.Forms.DockStyle]::Bottom) -DialogResult ([Windows.Forms.DialogResult]::OK) -ButtonAction {
    #//TODO Actions to be performed when OK button is clicked
    $form.Close()
    Write-Host "OK button clicked"
}
$cancelButton = Create-Button -ButtonName "cancelUserButton" -ButtonText "Cancel" -ButtonDockStyle ([System.Windows.Forms.DockStyle]::Bottom) -DialogResult ([Windows.Forms.DialogResult]::Cancel) -ButtonAction {
    #//TODO Actions to be performed when OK button is clicked
    $form.Close()
    Write-Host "Cancel button clicked"
}

$groupBoxControls.Controls.Add($okButton)
$groupBoxControls.Controls.Add($cancelButton)

#---------------------- edit groupBox ---------------------------------------




$form.Topmost = $true


if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    #//TODO Get the user Input
    Get-StringFromTextBox -TextBox $GivenNameTextBox
}
elseif ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
    # Cancel button was clicked, perform necessary actions
    Write-Host "Performing actions based on Cancel button click..."
}