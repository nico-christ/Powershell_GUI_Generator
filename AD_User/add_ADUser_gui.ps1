Import-Module ActiveDirectory

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

#$userProperties = Import-Csv -Delimiter "," -Path C:\Scripts\user_reg\Data\userdata.csv
$countryList = Import-Csv -Delimiter "," -Path C:\Scripts\user_reg\Data\country.csv
$officeList = @("Koeln", "Hamburg", "Sonstiges")
$driveList = [System.IO.DriveInfo]::GetDrives() | ForEach-Object { $_.Name }

$AccountPasswordSec = $null


<#------------------------------ functions------------------------------------
these are in the "gui_test.ps1"
#>

function New-GroupBox {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title,

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
    #$groupBox.Text = $Title
    $groupBox.Location = New-Object System.Drawing.Point($PosX, $PosY)
    $groupBox.Size = New-Object System.Drawing.Size($Width, $Height)

    $groupBoxTitleLabel = New-Object System.Windows.Forms.Label
    $groupBoxTitleLabel.Text = $Title
    $groupBoxTitleLabel.Location = New-Object System.Drawing.Point(6, -2)
    $groupBoxTitleLabel.AutoSize = $true
    $groupBoxTitleLabel.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
    $groupBox.Controls.Add($groupBoxTitleLabel)

    return $groupBox
}

function New-Label {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Content,

        [Parameter()]
        [int]$Width,
        [Parameter()]
        [int]$Height,

        [Parameter()]
        [int]$PosX,
        [Parameter()]
        [int]$PosY,

        [Parameter()]
        [ValidateSet('TopLeft', 'BottomLeft', 'TopRight', 'BottomRight')]
        [string]$Alignment = 'TopLeft'
    )

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Content

    $label.Location = New-Object System.Drawing.Point($PosX, $PosY)
    if ($Width -and $Height) {$label.Size = New-Object System.Drawing.Size($Width, $Height)}
    else {$label.AutoSize = $true}

    $alignmentMap = @{
        'TopLeft' = [System.Drawing.ContentAlignment]::TopLeft
        'BottomLeft' = [System.Drawing.ContentAlignment]::BottomLeft
        'TopRight' = [System.Drawing.ContentAlignment]::TopRight
        'BottomRight' = [System.Drawing.ContentAlignment]::BottomRight
    }
    $label.TextAlign = $alignmentMap[$Alignment]

    return $label
}

function New-TextBox {
    param (
        [Parameter()]
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
    $textBox.Location = New-Object System.Drawing.Point($PosX, $PosY)

    $textBox.BackColor = "LightGray"

    if ($Content) {$textBox.Text = $Content}

    if ($Width -and $Height) {$textBox.Size = New-Object System.Drawing.Size($Width, $Height)}
    else {$textBox.AutoSize = $true}

    return $textBox
}

function New-ComboBox {
    param (
        [Parameter(Mandatory=$true)]
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

    $comboBox = New-Object System.Windows.Forms.ComboBox
    $comboBox.Location = New-Object System.Drawing.Point($PosX, $PosY)

    $comboBox.DataSource = $List
    $comboBox.DisplayMember = "Name" #Displays only the name of the country

    $comboBox.BackColor = "LightGray"
    $comboBox.Font = New-Object System.Drawing.Font("Lucida Console",10,[System.Drawing.FontStyle]::Regular)

    if ($Width -and $Height) {$comboBox.Size = New-Object System.Drawing.Size($Width, $Height)}
    else {$comboBox.AutoSize = $true}

    return $comboBox
}

function New-CheckBox {
    param (
        [Parameter(Mandatory = $true)]
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
    $checkBox.Text = $Title

    $checkBox.Location = New-Object System.Drawing.Point($PosX, $PosY)

    #adds the width and height if given
    if ($Width -and $Height) {$checkBox.Size = New-Object System.Drawing.Size($Width, $Height)}
    else {$checkBox.AutoSize = $true}

    return $checkBox
}

function New-Button {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ButtonText,

        [Parameter()]
        [int]$PosX,
        [Parameter()]
        [int]$PosY
    )

    $button = New-Object System.Windows.Forms.Button
    $button.Text = $ButtonText

    $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    if ($ButtonText -eq "Cancel") {
        $button.BackColor = "Orange"
    } elseif ($ButtonText -eq "Create") {$button.BackColor = "LightGreen"}
    else {$button.BackColor = "LemonChiffon"}

    if ($PosX -and $PosY) {$button.Location = New-Object System.Drawing.Point($PosX,$PosY)}
    else {$button.Dock = [System.Windows.Forms.DockStyle]::Bottom}

    return $button
}

function New-PictureBox { # Create a PictureBox for displaying the icon
    param (
        [Parameter()]
        [int]$Width,
        [Parameter()]
        [int]$Height,

        [Parameter()]
        [int]$PosX,
        [Parameter()]
        [int]$PosY
    )
    $PictureBox = New-Object Windows.Forms.PictureBox
    $PictureBox.Image = [System.Drawing.Image]::FromFile("C:\Share\Wallpaper\Icons\question.png")
    $PictureBox.Location = New-Object Drawing.Point($PosX, $PosY)  # Position it to the right of the label

    if ($Width -and $Height) {
        $PictureBox.Size = New-Object System.Drawing.Size($Width, $Height)
    }

    return $PictureBox
}

function Get-Country {
    param (
        [Parameter()]
        [string]$Country
    )

    try {

        $matchingCountry = $countryList | Where-Object { $_.Name -eq $Country } # matching pair wird gesucht

        if ($matchingCountry) {

            return @{c = $matchingCountry.Value; co = $matchingCountry.Name}

        } else {

            throw "No matching country found."

        }

    } catch {

        #Start-Job -ScriptBlock $SpeakToUser -ArgumentList "Kein gültiges Land"
        Write-Host -ForegroundColor Red "There is no such country."

    }
    
}

function New-Password {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [ValidateRange(6, [int]::MaxValue)]
        [int]$Length = 6
    )

    if ($Length -lt 6) {
        throw "Password length must be at least 6 characters."
    }
    elseif ($Length -gt 20) {
        throw "Password length cannot exceed 20 characters."
    }

    #ASCII Character set for Password
    $CharacterSet = @{
            Uppercase   = (97..122) | Get-Random -Count $Length | % {[char]$_}
            Lowercase   = (65..90)  | Get-Random -Count $Length | % {[char]$_}
            Numeric     = (48..57)  | Get-Random -Count $length | % {[char]$_}
            SpecialChar = (33..47)+(58..64)+(91..96)+(123..126) | Get-Random -Count 10 | % {[char]$_}
    }

    #Frame Random Password from given character set
    $StringSet = $CharacterSet.Uppercase + $CharacterSet.Lowercase + $CharacterSet.Numeric + $CharacterSet.SpecialChar

    $password = -join(Get-Random -Count $Length -InputObject $StringSet)
    [System.Windows.Forms.MessageBox]::Show("Your password:`n$password`n`nPlease write it down!","Password",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information)
    
    $securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
    return $securePassword
}

function Set-AccountExpirationdate {
    
    if (!($AccountExpirationDatePicker.Checked)) {
        return $null
    }else {return $AccountExpirationDatePicker.Value}
    
}

function Show-ToolTip {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [System.Windows.Forms.Control]$control,
        [string]$text = $null,
        [int]$duration = 1000
    )
    if ([string]::IsNullOrWhiteSpace($text)) { $text = $control.Tag }
    $pos = [System.Drawing.Point]::new($control.Right, $control.Top)
    $objectTooTip.Show($text, $form, $pos, $duration)
}

#----------------------- create form ---------------------------------------------
#$form = New-Form -Title "New AD User" -Name "ADUserGUI" -StartPosition "Centerscreen" -Width 1000 -Height 730
$form = New-Object System.Windows.Forms.Form
$form.Text = "New AD-User"
$form.Size = New-Object System.Drawing.Size(1000, 730)
$form.StartPosition = "Centerscreen"
$form.Topmost = $false
$form.BackColor = "LightBlue"
$form.BackgroundImage = [System.Drawing.Image]::FromFile("C:\Share\Wallpaper\wp2132611-pepe-the-frog-wallpapers.jpg")
$form.ShowIcon = $True
$form.Icon = New-Object System.Drawing.Icon ("C:\Share\Wallpaper\Icons\user.ico")
$form.Add_KeyDown({if ($_.KeyCode -eq "Escape") { $form.Close() } }) # if escape, exit



$objectTooTip = New-Object System.Windows.Forms.ToolTip

#---------------------- create Groupboxes ----------------------------------------
$groupBoxGeneral = New-GroupBox -Title "General" -Width 280 -Height 375 -PosX 20 -PosY 20 # GroupBox um den Allgemein Tab ein zugeben
$groupBoxAddress = New-GroupBox -Title "Address" -Width 280 -Height 210 -PosX 20 -PosY 420 # GroupBox um den Adress Tab ein zu geben
$groupBoxAccount = New-GroupBox -Title "Account" -Width 280 -Height 370 -PosX 325 -PosY 20 # GroupBox um den Konto Tab ein zu geben
$groupBoxAccountOptions = New-GroupBox -Title "Account Options" -Width 250 -Height 250 -PosX 10 -PosY 60 # GroupBox um die Konto Optionen ein zu geben
$groupBoxPassword = New-GroupBox -Title "Password" -Width 280 -Height 50 -PosX 325 -PosY 400 # GroupBox um den Passwort Tab ein zu geben
$groupBoxProfile = New-GroupBox -Title "Profile" -Width 280 -Height 180 -PosX 325 -PosY 460 # GroupBox um den Passwort Tab ein zu geben
$groupBoxPhoneNumbers = New-GroupBox -Title "Phone Numbers" -Width 280 -Height 180 -PosX 620 -PosY 20
$groupBoxCompany = New-GroupBox -Title "Company" -Width 280 -Height 250 -PosX 620 -PosY 220


#------------------------------ create tab general -----------------------------------

$GivenNameLabel = New-Label -Content "First Name" -Width 80 -Height 30 -PosX 30 -PosY 20
$GivennamePictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 20
$GivennamePictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Enter Your First Name. (Your Parents gave your this one at your brith)"})   # you can play with the other parameters -text and -duration
$GivennamePictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$GivenNameTextBox = New-TextBox -Content "Fritz" -Width 120 -Height 30 -PosX 110 -PosY 20
$GivenNameTextBox.Add_TextChanged({
    $InitialsTextBox.Text = ($GivenNameTextBox.Text)[0]+($SurnameTextBox.Text)[0]
    $NameTextBox.Text = (($GivenNameTextBox.Text)[0] + $SurnameTextBox.Text).ToLower()
    $DisplayNameTextBox.Text = $GivenNameTextBox.Text + " " + $SurnameTextBox.Text
    $EmailAdressTextBox.Text = $GivenNameTextBox.Text.ToLower() + "." + $SurnameTextBox.Text.ToLower() + "@soprasteria.com"
})

$SurnameLabel = New-Label -Content "Surname" -Width 80 -Height 30 -PosX 30 -PosY 50
$SurnamePictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 50
$SurnamePictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Enter your last name. (Its your family name)"})   # you can play with the other parameters -text and -duration
$SurnamePictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$SurnameTextBox = New-TextBox -Content "Meier" -Width 120 -Height 30 -PosX 110 -PosY 50
$SurnameTextBox.Add_TextChanged({
    $InitialsTextBox.Text = ($GivenNameTextBox.Text)[0]+($SurnameTextBox.Text)[0]
    $NameTextBox.Text = $GivenNameTextBox.Text.ToLower()[0] + $SurnameTextBox.Text.ToLower()
    $DisplayNameTextBox.Text = $GivenNameTextBox.Text + " " + $SurnameTextBox.Text
    $EmailAdressTextBox.Text = $GivenNameTextBox.Text.ToLower() + "." + $SurnameTextBox.Text.ToLower() + "@soprasteria.com"
})

$InitialsLabel = New-Label -Content "Initials" -Width 80 -Height 30 -PosX 30 -PosY 80
$InitialsPictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 80
$InitialsPictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "First letter of your first name + first letter of your lastname"})   # you can play with the other parameters -text and -duration
$InitialsPictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$InitialsTextBox = New-TextBox -Content "FM" -Width 25 -Height 30 -PosX 110 -PosY 80

$NameLabel = New-Label -Content "Username" -Width 80 -Height 30 -PosX 30 -PosY 110
$NamePictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 110
$NamePictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "This is the username (most times 'm.mustermann')"})   # you can play with the other parameters -text and -duration
$NamePictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$NameTextBox = New-TextBox -Content "fritzmeier" -Width 120 -Height 30 -PosX 110 -PosY 110
$NameTextBox.Add_TextChanged({
    $UserPrincipalNameTextBox.Text = $NameTextBox.Text.ToLower() + "@azubi.dom"
})

$DisplayNameLabel = New-Label -Content "Displayname" -Width 80 -Height 30 -PosX 30 -PosY 140
$DisplayNamePictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 140
$DisplayNamePictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "This name gets displayed at your AD-Account"})   # you can play with the other parameters -text and -duration
$DisplayNamePictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$DisplayNameTextBox = New-TextBox -Content "Fritz Meier" -Width 120 -Height 30 -PosX 110 -PosY 140

$DescriptionLabel = New-Label -Content "Description" -Width 80 -Height 30 -PosX 30 -PosY 170
$DescriptionPictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 170
$DescriptionPictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Short description of this person"})   # you can play with the other parameters -text and -duration
$DescriptionPictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$DescriptionTextBox = New-TextBox -Content "This is a description." -Width 150 -Height 70 -PosX 110 -PosY 170
$DescriptionTextBox.Multiline = $true

$OfficeLabel = New-Label -Content "Office" -Width 80 -Height 30 -PosX 30 -PosY 250
$OfficePictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 250
$OfficePictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Enter the Office Building. (Only Koeln and Hamburg available)"})   # you can play with the other parameters -text and -duration
$OfficePictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$OfficeComboBox = New-ComboBox -List $officeList -Width 120 -Height 30 -PosX 110 -PosY 250

$OfficePhoneLabel = New-Label -Content "Office Phone" -Width 80 -Height 30 -PosX 30 -PosY 280
$OfficePhonePictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 280
$OfficePhonePictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Enter the your office phonenumber. It is your business number."})
$OfficePhonePictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$OfficePhoneTextBox = New-TextBox -Content "0123456789" -Width 120 -Height 30 -PosX 110 -PosY 280

$EmailAdressLabel = New-Label -Content "Email" -Width 80 -Height 30 -PosX 30 -PosY 310
$EmailAdressPictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 310
$EmailAdressPictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Enter your email adress form work. (Not your private one)"})
$EmailAdressPictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$EmailAdressTextBox = New-TextBox -Content "fritz.meier@soprasteria.com" -Width 150 -Height 30 -PosX 110 -PosY 310
$EmailAdressTextBox.Font = New-Object System.Drawing.Font("Consolas",8,[System.Drawing.FontStyle]::Regular)

$HomepageLabel = New-Label -Content "Website" -Width 80 -Height 30 -PosX 30 -PosY 340
$HomepagePictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 340
$HomepagePictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "If you got a webpage, you can enter it here."})
$HomepagePictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$HomepageTextBox = New-TextBox -Content "www.fritz-meier.com" -Width 150 -Height 30 -PosX 110 -PosY 340
$HomepageTextBox.Font = New-Object System.Drawing.Font("Consolas",8,[System.Drawing.FontStyle]::Regular)

$form.Controls.Add($groupBoxGeneral)
$groupBoxGeneral.Controls.AddRange(@(
    $GivenNameLabel,
    $GivenNameTextBox,
    $SurnameLabel,
    $SurnamePictueBox,
    $SurnameTextBox,
    $InitialsLabel,
    $InitialsPictueBox,
    $InitialsTextBox,
    $NameLabel,
    $NamePictueBox,
    $NameTextBox,
    $DisplayNameLabel,
    $DisplayNamePictueBox,
    $DisplayNameTextBox,
    $DescriptionLabel,
    $DescriptionPictueBox,
    $DescriptionTextBox,
    $OfficeLabel,
    $OfficePictueBox
    $OfficeComboBox,
    $OfficePhoneLabel,
    $OfficePhonePictueBox,
    $OfficePhoneTextBox,
    $EmailAdressLabel,
    $EmailAdressPictueBox,
    $EmailAdressTextBox,
    $HomepageLabel,
    $HomepagePictueBox,
    $HomepageTextBox
))
$groupBoxGeneral.Controls.Add($GivennamePictueBox)

#------------------------------------ create tab address----------------------------------------------------------------------------

$StreetAddressLabel = New-Label -Content "Street Address" -Width 80 -Height 30 -PosX 30 -PosY 20
$StreetAddressPictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 20
$StreetAddressPictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Enter your street and the number of your house"})
$StreetAddressPictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$StreetAddressTextBox = New-TextBox -Content "Musterstraße 13" -Width 150 -Height 30 -PosX 110 -PosY 20

$POBoxLabel = New-Label -Content "Post Box" -Width 80 -Height 30 -PosX 30 -PosY 50
$POBoxPictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 50
$POBoxPictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "If you got a post office box, please enter it here"})
$POBoxPictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$POBoxTextBox = New-TextBox -Content "MusterBox" -Width 120 -Height 30 -PosX 110 -PosY 50

$CityLabel = New-Label -Content "City" -Width 80 -Height 30 -PosX 30 -PosY 80
$CityPictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 80
$CityPictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Just enter your City bro. You can do that. (I hope so at least)"})
$CityPictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$CityTextBox = New-TextBox -Content "Koeln" -Width 120 -Height 30 -PosX 110 -PosY 80

$StateLabel = New-Label -Content "State" -Width 80 -Height 30 -PosX 30 -PosY 110
$StatePictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 110
$StatePictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Enter the state of your country. (Example: NRW)"})
$StatePictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$StateTextBox = New-TextBox -Content "Nord-Rhein-Westfalen" -Width 150 -Height 30 -PosX 110 -PosY 110

$PostalCodeLabel = New-Label -Content "Postal Code" -Width 80 -Height 30 -PosX 30 -PosY 140
$PostalCodePictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 140
$PostalCodePictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Enter the postcode of your city. Mostly 5 digits."})
$PostalCodePictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$PostalCodeTextBox = New-TextBox -Content "57235" -Width 120 -Height 30 -PosX 110 -PosY 140

$CountryLabel = New-Label -Content "Country" -Width 80 -Height 30 -PosX 30 -PosY 170
$CountryPictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 170
$CountryPictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Select your the country you are living in."})
$CountryPictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$CountryComboBox = New-ComboBox -List $countryList -Width 150 -Height 30 -PosX 110 -PosY 170

$form.Controls.Add($groupBoxAddress)
$groupBoxAddress.Controls.AddRange( @(
    $StreetAddressLabel,
    $StreetAddressPictueBox,
    $StreetAddressTextBox,
    $POBoxLabel,
    $POBoxPictueBox,
    $POBoxTextBox,
    $CityLabel,
    $CityPictueBox,
    $CityTextBox,
    $StateLabel,
    $StatePictueBox,
    $StateTextBox,
    $PostalCodeLabel,
    $PostalCodePictueBox,
    $PostalCodeTextBox,
    $CountryLabel,
    $CountryPictueBox,
    $CountryComboBox
    ))

#---------------------------------- create tab account ------------------------------------------------------------------------------------
$form.Controls.Add($groupBoxAccount)
$UserPrincipal = New-Label -Content "Login Name Domain" -Width 80 -Height 30 -PosX 30 -PosY 20 #username
$UserPrincipalPictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 20
$UserPrincipalPictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Select the logon name for the domain."})
$UserPrincipalPictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$UserPrincipalNameTextBox = New-TextBox -Content "f.meier" -Width 120 -Height 30 -PosX 110 -PosY 20

#the $accountOptionGroupBox is right here

$AccountExpirationDateLabel = New-Label -Content "Expiration Date" -Width 80 -Height 25 -PosX 30 -PosY 325
$AccountExpirationDatePictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 325
$AccountExpirationDatePictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Set the account expiration date or just let it unchecked to set it to never."})
$AccountExpirationDatePictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

# Create a date input field
$AccountExpirationDatePicker = New-Object System.Windows.Forms.DateTimePicker
$AccountExpirationDatePicker.Location = New-Object System.Drawing.Point(110,325)
$AccountExpirationDatePicker.Size = New-Object System.Drawing.Size(150,30)
$AccountExpirationDatePicker.Format = [System.Windows.Forms.DateTimePickerFormat]::Short
$AccountExpirationDatePicker.ShowCheckBox = $true
$AccountExpirationDatePicker.Checked = $false

$groupBoxAccount.Controls.AddRange( @(
    $UserPrincipal,
    $UserPrincipalPictueBox,
    $UserPrincipalNameTextBox,
    $AccountExpirationDateLabel,
    $AccountExpirationDatePictueBox,
    $AccountExpirationDatePicker
    ))

#---------------------------------- create sub-tab account options ---------------------------
$groupBoxAccount.Controls.Add($groupBoxAccountOptions)

$ChangePasswordAtLogonCheckBox = New-CheckBox -Title "Change Password At Logon" -Width 200 -Height 30 -PosX 10 -PosY 20
$ChangePasswordAtLogonPictueBox = New-PictureBox -Width 20 -Height 20 -PosX 210 -PosY 20
$ChangePasswordAtLogonPictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Check if the user should change his password at next logon."})
$ChangePasswordAtLogonPictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$CannotChangePasswordCheckBox = New-CheckBox -Title "Cannot Change Password" -Width 200 -Height 30 -PosX 10 -PosY 50
$CannotChangePasswordPictueBox = New-PictureBox -Width 20 -Height 20 -PosX 210 -PosY 50
$CannotChangePasswordPictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Check if the user should not change the password."})
$CannotChangePasswordPictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$PasswordNeverExpiresCheckBox = New-CheckBox -Title "Password Never Expires" -Width 200 -Height 30 -PosX 10 -PosY 80
$PasswordNeverExpiresPictueBox = New-PictureBox -Width 20 -Height 20 -PosX 210 -PosY 80
$PasswordNeverExpiresPictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Check if the password should never expire."})
$PasswordNeverExpiresPictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$AllowReversiblePasswordEncryptionCheckBox = New-CheckBox -Title "Allow reversible Password" -Width 200 -Height 30 -PosX 10 -PosY 110
$AllowReversiblePasswordEncryptionPictueBox = New-PictureBox -Width 20 -Height 20 -PosX 210 -PosY 110
$AllowReversiblePasswordEncryptionPictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Check if the password encryption should be reversible."})
$AllowReversiblePasswordEncryptionPictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$EnabledCheckBox = New-CheckBox -Title "Enable Account" -Width 200 -Height 30 -PosX 10 -PosY 140
$EnablePictueBox = New-PictureBox -Width 20 -Height 20 -PosX 210 -PosY 140
$EnablePictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Check if the user account should be enabled."})
$EnablePictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$SmartcardLogonRequiredCheckBox = New-CheckBox -Title "Scmartcard required for logon" -Width 200 -Height 30 -PosX 10 -PosY 170
$SmartcardLogonRequiredPictueBox = New-PictureBox -Width 20 -Height 20 -PosX 210 -PosY 170
$SmartcardLogonRequiredPictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Check if the the account requires a smartcard to login."})
$SmartcardLogonRequiredPictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$AccountNotDelegatedCheckBox = New-CheckBox -Title "Account is confidential and cannot delegated" -Width 200 -Height 30 -PosX 10 -PosY 200
$AccountNotDelegatedPictueBox = New-PictureBox -Width 20 -Height 20 -PosX 210 -PosY 200
$AccountNotDelegatedPictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Check if the account should not be delegated."})
$AccountNotDelegatedPictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })


$groupBoxAccountOptions.Controls.AddRange(@(
    $ChangePasswordAtLogonCheckBox,
    $ChangePasswordAtLogonPictueBox,
    $CannotChangePasswordCheckBox,
    $CannotChangePasswordPictueBox,
    $PasswordNeverExpiresCheckBox,
    $PasswordNeverExpiresPictueBox,
    $EnabledCheckBox,
    $EnablePictueBox,
    $AllowReversiblePasswordEncryptionCheckBox,
    $AllowReversiblePasswordEncryptionPictueBox,
    $SmartcardLogonRequiredCheckBox,
    $SmartcardLogonRequiredPictueBox,
    $AccountNotDelegatedCheckBox,
    $AccountNotDelegatedPictueBox
    ))

#-------------------------------- passwordsection ---------------------------------------------------
$passwordLabel = New-Label -Content "Passwordlength" -Width 85 -Height 20 -PosX 30 -PosY 20
$passwordPictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 20
$passwordPictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Use the arrows to change the password length. Click on 'Generate' to generate arandom password with the set length."})
$passwordPictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$passwordLengthUpDown = New-Object System.Windows.Forms.NumericUpDown
$passwordLengthUpDown.Minimum = 6
$passwordLengthUpDown.Maximum = 20
$passwordLengthUpDown.Value = 8 #default Value
$passwordLengthUpDown.Location = New-Object System.Drawing.Point(125,20)
$passwordLengthUpDown.Size = New-Object System.Drawing.Size(50,30)

$passwordButton = New-Button -ButtonText "Generate" -PosX 195 -PosY 20


$form.Controls.Add($groupBoxPassword)
$groupBoxPassword.Controls.AddRange(@(
    $passwordLabel,
    $passwordPictueBox,
    $passwordLengthUpDown,
    $passwordButton
    ))

#-------------------------------- Profile ----------------------------------------------------
$HomeDriveLabel = New-Label -Content "Home directory drive letter" -Width 90 -Height 30 -PosX 30 -PosY 20
$HomeDrivePictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 20
$HomeDrivePictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Set the driveletter for the homedrive for the user."})
$HomeDrivePictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$HomeDriveComboBox = New-ComboBox -List $driveList -Width 50 -Height 30 -PosX 120 -PosY 20

$HomeDirectoryLabel = New-Label -Content "Profile Directory" -Width 80 -Height 30 -PosX 30 -PosY 50
$HomeDirectoryPictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 50
$HomeDirectoryPictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Set the Home Directorypath for the user"})
$HomeDirectoryPictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$HomeDirectoryTextBox = New-TextBox -Width 160 -Height 30 -PosX 110 -PosY 50

$HomeDirectorySelectButton = New-Button -ButtonText "Browse" -PosX 195 -PosY 80
$HomeDirectorySelectButton.Add_Click({ #Adds a Button to select a home directory folder
    $folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderDialog.SelectedPath = $HomeDriveComboBox.Text
    $result = $folderDialog.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK)
    {
        $HomeDirectoryTextBox.Text = $folderDialog.SelectedPath
    }
    elseif ($result -eq [System.Windows.Forms.DialogResult]::Cancel)
    {
        $folderDialog.Dispose()  # Dispose the dialog to release resources
    }
})

$scriptPathLabel = New-Label -Content "Select a Script that is run at users logon" -Width 165 -Height 30 -PosX 30 -PosY 110
$scriptPathPictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 110
$scriptPathPictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Select ascript that launches when the user login."})
$scriptPathPictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$ScriptPathButton = New-Button -ButtonText "Browse" -PosX 195 -PosY 110
$ScriptPathButton.Add_Click({
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.InitialDirectory = "C:\"
    $dialog.Filter = "All files (*.*)|*.*"
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK)
    {
        $scriptPathShowLabel.Text = $dialog.FileName
        $User.ScriptPath = $dialog.FileName
    }
})
$scriptPathShowLabel = New-Label -Content "No Script Selected" -Width 230 -Height 20 -PosX 20 -PosY 140

$form.Controls.Add($groupBoxProfile)
$groupBoxProfile.Controls.AddRange(@(
    $HomeDriveLabel,
    $HomeDrivePictueBox,
    $HomeDriveComboBox,
    $HomeDirectoryLabel,
    $HomeDirectoryPictueBox,
    $HomeDirectoryTextBox,
    $HomeDirectorySelectButton,
    $scriptPathLabel,
    $scriptPathPictueBox,
    $ScriptPathButton,
    $scriptPathShowLabel
))
#-------------------------------- //TODOPhone numbers ---------------------------------------------------------
$HomePhoneLabel = New-Label -Content "Private Phonenumber" -Width 100 -Height 30 -PosX 30 -PosY 20
$HomePhonePictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 20
$HomePhonePictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Enter your private phonenumber from your house. (If you got one)"})
$HomePhonePictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$HomePhoneTextBox = New-TextBox -Content "01254673" -Width 120 -Height 30 -PosX 130 -PosY 20

$PagerNumberLabel = New-Label -Content "Pager Number" -Width 80 -Height 30 -PosX 30 -PosY 50
$PagerNumberPictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 50
$PagerNumberPictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Enter the number of your pager if you got one."})
$PagerNumberPictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$PagerNumberTextBox = New-TextBox -Content "034578" -Width 120 -Height 30 -PosX 130 -PosY 50


$MobilePhoneLabel = New-Label -Content "Mobil Phone" -Width 80 -Height 30 -PosX 30 -PosY 80
$MobilePhonePictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 80
$MobilePhonePictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Enter the number of your smartphone."})
$MobilePhonePictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$MobilePhoneTextBox = New-TextBox -Content "037586235" -Width 120 -Height 30 -PosX 130 -PosY 80

$FaxLabel = New-Label -Content "Fax" -Width 80 -Height 30 -PosX 30 -PosY 110
$FaxPictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 110
$FaxPictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Enter the number of your fax."})
$FaxPictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$FaxTextBox = New-TextBox -Content "012653" -Width 120 -Height 30 -PosX 130 -PosY 110

$IPTelephoneLabel = New-Label -Content "IP Telephone" -Width 80 -Height 30 -PosX 30 -PosY 140
$IPTelephonePictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 140
$IPTelephonePictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Enter the number of your IP-telephone."})
$IPTelephonePictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$IPTelephoneTextBox = New-TextBox -Content "0896983" -Width 120 -Height 30 -PosX 130 -PosY 140

$form.Controls.Add($groupBoxPhoneNumbers)
$groupBoxPhoneNumbers.Controls.AddRange(@(
    $HomePhoneLabel,
    $HomePhonePictueBox,
    $HomePhoneTextBox,
    $PagerNumberLabel,
    $PagerNumberPictueBox,
    $PagerNumberTextBox,
    $MobilePhoneLabel,
    $MobilePhonePictueBox,
    $MobilePhoneTextBox,
    $FaxLabel,
    $FaxPictueBox,
    $FaxTextBox,
    $IPTelephoneLabel,
    $IPTelephonePictueBox,
    $IPTelephoneTextBox
))
#-------------------------------- User Company -------------------------------------------------------
$CompanyLabel = New-Label -Content "Company"-Width 80 -Height 30 -PosX 30 -PosY 20
$CompanyPictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 20
$CompanyPictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Enter the company you are working for."})
$CompanyPictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$CompanyTextBox = New-TextBox -Content "Sopra Steria" -Width 120 -Height 30 -PosX 110 -PosY 20

$DepartmentLabel = New-Label -Content "Department" -Width 80 -Height 30 -PosX 30 -PosY 50 #Abteilung
$DepartmentPictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 50
$DepartmentPictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Enter the Department of your company, you are working for."})
$DepartmentPictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$DepartmentTextBox = New-TextBox -Content "MACS" -Width 120 -Height 30 -PosX 110 -PosY 50

$DivisionLabel = New-Label -Content "Division" -Width 80 -Height 30 -PosX 30 -PosY 80
$DivisionPictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 80
$DivisionPictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Enter the Division of your company, you are working for."})
$DivisionPictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$DivisionTextBox = New-TextBox -Content "Division?" -Width 120 -Height 30 -PosX 110 -PosY 80
#
$ManagerLabel = New-Label -Content "Manager" -Width 80 -Height 30 -PosX 30 -PosY 110
$ManagerPictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 110
$ManagerPictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Enter your manager / boss you are working for."})
$ManagerPictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$ManagerSelectButton = New-Button -ButtonText "Select" -PosX 145 -PosY 110
$ManagerSelectButton.Add_Click({

    # Retrieve a list of AD users
    $usersList = Get-ADUser -Filter * | Select-Object -Property SamAccountName

    $userDialog = New-Object System.Windows.Forms.Form
    $userDialog.Text = "Select AD User"
    $userDialog.Size = New-Object System.Drawing.Size(300, 200)
    $userDialog.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $userDialog.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

    $userComboBox = New-ComboBox -List $usersList -Width 250 -PosX 10 -PosY 10
    $userComboBox.DisplayMember = "SamAccountName"
    
    foreach ($user in $users)
    {
        $userComboBox.Items.Add($user.SamAccountName)
    }
    
    $userDialog.Controls.Add($userComboBox)

    $selectButton = New-Object System.Windows.Forms.Button
    $selectButton.Text = "Select"
    $selectButton.Location = New-Object System.Drawing.Point(120, 40)
    $selectButton.Add_Click({
        $selectedUser = $userComboBox.SelectedItem
        $ManagerSelectLabel.Text = "Selected Manager: $selectedUser"
        $userDialog.Close()
        $userDialog.Dispose()
    })
    $userDialog.Controls.Add($selectButton)

    $userDialog.ShowDialog() | Out-Null
})
$ManagerSelectLabel = New-Label -Content "*No Manager Selected*" -Width 200 -Height 30 -PosX 30 -PosY 140
#>
$EmployeeIDLabel = New-Label -Content "EmployeeID" -Width 80 -Height 30 -PosX 30 -PosY 170
$EmployeeIDPictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 170
$EmployeeIDPictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Enter your employee ID."})
$EmployeeIDPictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$EmployeeIDTextBox = New-TextBox -Content "42" -Width 120 -Height 30 -PosX 130 -PosY 170

$EmployeeNumberLabel = New-Label -Content "EmployeeNumber" -Width 100 -Height 30 -PosX 30 -PosY 200
$EmployeeNumberPictueBox = New-PictureBox -Width 20 -Height 20 -PosX 14 -PosY 200
$EmployeeNumberPictueBox.Add_MouseEnter({ Show-ToolTip -control $this -text "Enter your employee number."})
$EmployeeNumberPictueBox.Add_MouseLeave({ $objectTooTip.Hide($this) })

$EmployeeNumberTextBox = New-TextBox -Content "423" -Width 120 -Height 30 -PosX 130 -PosY 200

$form.Controls.Add($groupBoxCompany)
$groupBoxCompany.Controls.AddRange(@(
    $CompanyLabel,
    $CompanyPictueBox,
    $CompanyTextBox,
    $DepartmentLabel,
    $DepartmentPictueBox,
    $DepartmentTextBox,
    $DivisionLabel,
    $DivisionPictueBox,
    $DivisionTextBox,
    $ManagerLabel,
    $ManagerPictueBox,
    $ManagerSelectLabel,
    $ManagerSelectButton,
    $EmployeeIDLabel,
    $EmployeeIDPictueBox,
    $EmployeeIDTextBox,
    $EmployeeNumberLabel,
    $EmployeeNumberPictueBox,
    $EmployeeNumberTextBox
))
#---------------------- create and cancel buttons -----------------------------


$okButton = New-Button -ButtonText "Create"
$okButton.DialogResult = ([Windows.Forms.DialogResult]::OK)

$cancelButton = New-Button -ButtonText "Cancel"
$cancelButton.DialogResult = ([Windows.Forms.DialogResult]::Cancel)

$form.Controls.Add($okButton)
$form.Controls.Add($cancelButton)

#---------------------- edit groupBox ---------------------------------------

# Show the form and get user input


# Store the user input in a variable to use later

$User = [ordered]@{
    GivenName = $GivenNameTextBox.Text
    Surname = $SurnameTextBox.Text
    Initials = $InitialsTextBox.Text
    Name = $NameTextBox.Text #Username
    DisplayName = $DisplayNameTextBox.Text
    Description = $DescriptionTextBox.Text
    Office = $OfficeComboBox.Text
    OfficePhone = $OfficePhoneTextBox.Text
    EmailAddress = $EmailAdressTextBox.Text
    HomePage = $HomepageTextBox.Text

    StreetAddress = $StreetAddressTextBox.Text
    POBox = $POBoxTextBox.Text
    City = $CityTextBox.Text
    State = $StateTextBox.Text
    PostalCode = $PostalCodeTextBox.Text
    Country = $null

    UserPrincipalName = $UserPrincipalNameTextBox.Text
    AccountExpirationDate = $null

    ChangePasswordAtLogon = $ChangePasswordAtLogonCheckBox.Checked
    CannotChangePassword = $CannotChangePasswordCheckBox.Checked
    PasswordNeverExpires = $PasswordNeverExpiresCheckBox.Checked
    AllowReversiblePasswordEncryptionCheckBox = $AllowReversiblePasswordEncryptionCheckBox.Checked
    Enabled = $EnabledCheckBox.Checked
    AllowReversiblePasswordEncryption = $AllowReversiblePasswordEncryptionCheckBox.Checked
    SmartcardLogonRequired = $SmartcardLogonRequiredCheckBox.Checked
    AccountNotDelegated = $AccountNotDelegatedCheckBox.Checked

    HomeDirectory = $HomeDirectoryTextBox.Text
    HomeDrive = $HomeDriveComboBox.Text
    ScriptPath = $null

    HomePhone = $HomepageTextBox.Text
    MobilePhone = $MobilePhoneTextBox.Text
    Fax = $FaxTextBox.Text
}

$passwordButton.Add_Click({
    $AccountPasswordSec = New-Password -Length $passwordLengthUpDown.Value
})

$okButton.Add_Click({
    $User.AccountExpirationDate = Set-AccountExpirationdate
    if ($AccountPasswordSec -eq $null) {$AccountPasswordSec = New-Password -Length $passwordLengthUpDown.Value}
    [System.Windows.Forms.MessageBox]::Show("User creation '" + $User.DisplayName + "' successful.","New AD-User",0,[System.Windows.Forms.MessageBoxIcon]::Information)
    Write-Host -f DarkCyan $AccountPasswordSec
})

$cancelButton.Add_Click({$form.Close()})

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    try {
        #New-ADUser @User
        $User
        Write-Host -f Green $User.DisplayName "creation successful"
    }
    catch {Write-Host -f Red "Something went wrong. Could not create User"}

    try {
    $countryName = $CountryComboBox.Text
    Set-ADUser -Identity $User.Name -Replace (Get-Country -Country $countryName)
    }
    catch {
        Write-Host -f Red "Could not set Country"
    }
    try {
        Set-ADAccountPassword -Identity User.Name -Reset -NewPassword $AccountPasswordSec
    }
    catch {
        Write-Host -f Red "Could not set Password."
    }
}
elseif ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
    # Cancel button was clicked, perform necessary actions
    Write-Host -f DarkYellow "creation canceled"
}