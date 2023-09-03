Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#--------------------      functions     ---------------------------------
function Create-Form {
    param (
        [string]$formName

    )
    
}
function Create-Label {
    param (
        [string]$lableName
        [string]$labelContend
    )
    
}

function Create-TextBox {
    param (
        [strings]$textBoxContend
    )
    
}

function Create-Button {
    param (
        [string]$buttonText
    )
    
}

function Create-List {
    param (
        [System.Object]$listObjects
    )
    
}

#------------- create form --------------------------------------------
$form = New-Object System.Windows.Forms.Form
$form.Text = 'GUI Generator'
$form.Size = New-Object System.Drawing.Size(300,200)
$form.StartPosition = 'CenterScreen'

#---------------------first groupBox ----------------------------------------------
$groupBox1 = New-Object System.Windows.Forms.GroupBox


#--------------------- Buttons for creation of GUI or cancel in a groupbox ---------------------------------
$groupBoxCreateCancleButton = New-Object System.Windows.Forms.GroupBox
$createGUIButton = New-Object System.Windows.Forms.Button
$cancleGUIButton = New-Object System.Windows.Forms.Button
$groupBoxCreateCancleButton.Controls.Add($createGUIButton)
$groupBoxCreateCancleButton.Controls.Add($cancelGUIButton)


#------------------ Edit creatio button ----------------------
$createGUIButton.Location = New-Object System.Drawing.Point($xPosCreateGUIButton, $yPosCreateGUIButton)
$createGUIButton.Size = New-Object System.Drawing.Size($xSizeCreateGUIButton,$ySizeCreateGUIButton)





$form.Topmost = $true

#$form.Add_Shown({$textBox.Select()})
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $x = $textBox.Text
    $x
}
