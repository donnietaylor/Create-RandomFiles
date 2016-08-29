
<#
	.SYNOPSIS
		Creates a number of auto-generated files in the spcified directories.
	
	.DESCRIPTION
		This function will supply any number of files approximately at the size you request.  Rather than setting a file size, this function actually fills the files with text until they reach the requested size.  You can control the number of files, size of files, and whether or not to create random sub-directories.
	
	.PARAMETER Path
		The top level path where the script will begin to create files.   C:\Temp, for example
	
	.PARAMETER FileTypes
		The types of files to create.  This parameter expects an array of values.  For example:  'log','log1','log2'
	
	.PARAMETER Size
		Size of each individual file.  This parmeter is added to, or subtracted from, by the variance parameter.  This value is in Mb.  Exact sizes will vary, and larger file sizes will lead to larger variance.
	
	.PARAMETER Variance
		This parameter is added to, or subtracted from, the Size parameter to get a semi-random file size.  Blocks of text are added to the files, so exact file sizes will be random within a range.
	
	.PARAMETER SubDirectories
		Specify if this script should create subdirectories under the directory specified by the Path parameter.  Directories will have random names similar to file names, and there is a random chance of them being created (specified by the SubDirectoryCreateChance parameter)
	
	.PARAMETER Count
		The number of files to create under the directory specified by the Path parameter
	
	.PARAMETER SubDirectoryCreateChance
		The chance that a subdirectory will be created.  Larger numbers here will actually make it less likely that a subdirectory is created.  A number of 20 means that 1-in-20 will create a subdirectory.  A number of 100 means that 1-100 will create a subdirectory.
	
	.EXAMPLE
		PS C:\> Create-Files -Path c:\Temp\blog -FileTypes log, log1, log2, log3, log4, log5, log6, log7, log8 -Size 3 -Count 100
	
	.EXAMPLE
		PS C:\> Create-Files -Path c:\Temp\blog -FileTypes log, log1, log2, log3, log4, log5, log6, log7, log8 -Size 1 -Count 20000 -SubDirectories True -SubDirectoryCreateChance 50
	
	.EXAMPLE
		PS C:\> Create-Files -Path c:\Temp\blog -FileTypes log, log1, log2, log3, log4, log5, log6, log7, log8 -Size 10 -Count 50 -Variance 4 -SubDirectories True -SubDirectoryCreateChance 10
	
	.NOTES
		Additional information about the function.
#>
function Create-Files
{
	[CmdletBinding(PositionalBinding = $true)]
	param
	(
		[Parameter(Mandatory = $true,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   ValueFromRemainingArguments = $true,
				   Position = 0)]
		[ValidateNotNullOrEmpty()]
		[Alias('FilePath')]
		[string]$Path,
		[Parameter(Mandatory = $true,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   ValueFromRemainingArguments = $true,
				   Position = 1)]
		[ValidateNotNullOrEmpty()]
		[array]$FileTypes,
		[Parameter(Mandatory = $true,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   ValueFromRemainingArguments = $true,
				   Position = 2)]
		[ValidateNotNullOrEmpty()]
		[Alias('FileSize')]
		[int]$Size,
		[Parameter(ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   ValueFromRemainingArguments = $true,
				   Position = 4)]
		[ValidateNotNullOrEmpty()]
		[Alias('Random', 'RandomSize', 'RandomAmount')]
		[int]$Variance,
		[Parameter(ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   ValueFromRemainingArguments = $true,
				   Position = 5)]
		[ValidateSet('true', 'false', IgnoreCase = $true)]
		[string]$SubDirectories,
		[Parameter(Mandatory = $true,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   ValueFromRemainingArguments = $true,
				   Position = 3)]
		[ValidateNotNullOrEmpty()]
		[Alias('FileCount')]
		[int]$Count,
		[Parameter(ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   ValueFromRemainingArguments = $true)]
		[int]$SubDirectoryCreateChance = 20
	)
	
	Begin
	{
		$blockoftext = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut eros et nisl sagittis vestibulum. Nullam nulla eros, ultricies sit amet, nonummy id, imperdiet feugiat, pede. Sed lectus. Donec mollis hendrerit risus. Phasellus nec sem in justo pellentesque facilisis. Etiam imperdiet imperdiet orci. Nunc nec neque. Phasellus leo dolor, tempus non, auctor et, hendrerit quis, nisi. Curabitur ligula sapien, tincidunt non, euismod vitae, posuere imperdiet, leo. Maecenas malesuada. Praesent congue erat at massa. Sed cursus turpis vitae tortor. Donec posuere vulputate arcu. Phasellus accumsan cursus velit. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed aliquam, nisi quis porttitor congue, elit erat euismod orci, ac placerat dolor lectus quis orci. Phasellus consectetuer vestibulum elit. Aenean tellus metus, bibendum sed, posuere ac, mattis non, nunc. Vestibulum fringilla pede sit amet augue. In turpis. Pellentesque posuere. Praesent turpis. Aenean posuere, tortor sed cursus feugiat, nunc augue blandit nunc, eu sollicitudin urna dolor sagittis lacus. Donec elit libero, sodales nec, volutpat a, suscipit non, turpis. Nullam sagittis. Suspendisse pulvinar, augue ac venenatis condimentum, sem libero volutpat nibh, nec pellentesque velit pede quis nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Fusce id purus. Ut varius tincidunt libero. Phasellus dolor. Maecenas vestibulum mollis diam. Pellentesque ut neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. In dui magna, posuere eget, vestibulum et, tempor auctor, justo. In ac felis quis tortor malesuada pretium. Pellentesque auctor neque nec urna. Proin sapien ipsum, porta a, auctor quis, euismod ut, mi. Aenean viverra rhoncus pede. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Ut non enim eleifend felis pretium feugiat. Vivamus quis mi. Phasellus a est. Phasellus magna. In hac habitasse platea dictumst. Curabitur at lacus ac velit ornare lobortis. Curabitur a felis in nunc fringilla tristique. Morbi mattis ullamcorper velit. Phasellus gravida semper nisi. Nullam vel sem. Pellentesque libero tortor, tincidunt et, tincidunt eget, semper nec, quam. Sed hendrerit. Morbi ac felis. Nunc egestas, augue at pellentesque laoreet, felis eros vehicula leo, at malesuada velit leo quis pede. Donec interdum, metus et hendrerit aliquet, dolor diam sagittis ligula, eget egestas libero turpis vel mi. Nunc nulla. Fusce risus nisl, viverra et, tempor et, pretium in, sapien. Donec venenatis vulputate lorem. Morbi nec metus. Phasellus blandit leo ut odio. Maecenas ullamcorper, dui et placerat feugiat, eros pede varius nisi, condimentum viverra felis nunc et lorem. Sed magna purus, fermentum eu, tincidunt eu, varius ut, felis. In auctor lobortis lacus. Quisque libero metus, condimentum nec, tempor a, commodo mollis, magna. Vestibulum ullamcorper mauris at ligula. Fusce fermentum. Nullam cursus lacinia erat. Praesent blandit laoreet nibh. Fusce convallis metus id felis luctus adipiscing. Pellentesque egestas, neque sit amet convallis pulvinar, justo nulla eleifend augue, ac auctor orci leo non est. Quisque id mi. Ut tincidunt tincidunt erat. Etiam feugiat lorem non metus. Vestibulum dapibus nunc ac augue. Curabitur vestibulum aliquam leo. Praesent egestas neque eu enim. In hac habitasse platea dictumst. Fusce a quam. Etiam ut purus mattis mauris sodales aliquam. Curabitur nisi. Quisque malesuada placerat nisl. Nam ipsum risus, rutrum vitae, vestibulum eu, molestie vel, lacus. Sed augue ipsum, egestas nec, vestibulum et, malesuada adipiscing, dui. Vestibulum facilisis, purus nec pulvinar iaculis, ligula mi congue nunc, vitae euismod ligula urna in dolor. Mauris sollicitudin fermentum libero. Praesent nonummy mi in odio. Nunc interdum lacus sit amet orci. Vestibulum rutrum, mi nec elementum vehicula, eros quam gravida nisl, id fringilla neque ante vel mi. Morbi mollis tellus ac sapien. Phasellus volutpat, metus eget egestas mollis, lacus lacus blandit dui, id egestas quam mauris ut lacus. Fusce vel dui. Sed in libero ut nibh placerat accumsan. Proin faucibus arcu quis ante. In consectetuer turpis ut velit. Nulla sit amet est. Praesent metus tellus, elementum eu, semper a, adipiscing nec, purus. Cras risus ipsum, faucibus ut, ullamcorper id, varius ac, leo. Suspendisse feugiat. Suspendisse enim turpis, dictum sed, iaculis a, condimentum nec, nisi. Praesent nec nisl a purus blandit viverra. Praesent ac massa at ligula laoreet iaculis. Nulla neque dolor, sagittis eget, iaculis quis, molestie non, velit. Mauris turpis nunc, blandit et, volutpat molestie, porta ut, ligula. Fusce pharetra convallis urna. Quisque ut nisi. Donec mi odio, faucibus at, scelerisque quis, convallis in, nisi. Suspendisse non nisl sit amet velit hendrerit rutrum. Ut leo. Ut a nisl id ante tempus hendrerit. Proin pretium, leo ac pellentesque mollis, felis nunc ultrices eros, sed gravida augue augue mollis justo. Suspendisse eu ligula. Nulla facilisi. Donec id justo. Praesent porttitor, nulla vitae posuere iaculis, arcu nisl dignissim dolor, a pretium mi sem ut ipsum. Curabitur suscipit suscipit tellus. Praesent vestibulum dapibus nibh. Etiam iaculis nunc ac metus. Ut id nisl quis enim dignissim sagittis. Etiam sollicitudin, ipsum eu pulvinar rutrum, tellus ipsum laoreet sapien, quis venenatis ante odio sit amet eros. Proin magna. Duis vel nibh at velit scelerisque suscipit. Curabitur turpis. Vestibulum suscipit nulla quis orci. Fusce ac felis sit amet ligula pharetra condimentum. Maecenas egestas arcu quis ligula mattis placerat. Duis lobortis massa imperdiet quam. Suspendisse potenti. Pellentesque commodo eros a enim. Vestibulum turpis sem, aliquet eget, lobortis pellentesque, rutrum eu, nisl. Sed libero. Aliquam erat volutpat. Etiam vitae tortor. Morbi vestibulum volutpat enim. Aliquam eu nunc. Nunc sed turpis. Sed mollis, eros et ultrices tempus, mauris ipsum aliquam libero, non adipiscing dolor urna a orci. Nulla porta dolor. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos hymenaeos. Pellentesque dapibus hendrerit tortor. Praesent egestas tristique nibh. Sed a libero. Cras varius. Donec vitae orci sed dolor rutrum auctor. Fusce egestas elit eget lorem. Suspendisse nisl elit, rhoncus eget, elementum ac, condimentum eget, diam. Nam at tortor in tellus interdum sagittis. Aliquam lobortis. Donec orci lectus, aliquam ut, faucibus non, euismod id, nulla. Curabitur blandit mollis lacus. Nam adipiscing. Vestibulum eu odio. Vivamus laoreet. Nullam tincidunt adipiscing enim. Phasellus tempus. Proin viverra, ligula sit amet ultrices semper, ligula arcu tristique sapien, a accumsan nisi mauris ac eros. Fusce neque. Suspendisse faucibus, nunc et pellentesque egestas, lacus ante convallis tellus, vitae iaculis lacus elit id tortor. Vivamus aliquet elit ac nisl. Fusce fermentum odio nec arcu. Vivamus euismod mauris. In ut quam vitae odio lacinia tincidunt. Praesent ut ligula non mi varius sagittis. Cras sagittis. Praesent ac sem eget est egestas volutpat. Vivamus consectetuer hendrerit lacus. Cras non dolor. Vivamus in erat ut urna cursus vestibulum. Fusce commodo aliquam arcu. Nam commodo suscipit quam. Quisque id odio. Praesent venenatis metus at tortor pulvinar varius. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vita"
		$verbs = (Get-Verb).verb
		$group = (Get-Verb).group
		$Size / 1MB | Out-Null
		$Variance / 1MB | Out-Null
		$directories = @()
		$directories += 'create'
		try
		{
			. .\invoke-parallel.ps1
		}
		catch
		{
			Write-Verbose "Unable to find invoke-parallel.ps1 in this directory.  Please add invoke-parallel to the same directory as this script."
		}
	}
	Process
	{

		[array] $Count= 1..$count
		invoke-parallel -Throttle 50 -inputobject $Count -importmodules -importvariables -scriptblock {
			$filesize = $size
			$stringBuilder = New-Object System.Text.StringBuilder
			$filecontent = New-Object System.Collections.Generic.List[System.String]
			$filepart1 = $verbs | Get-Random
			$filepart2 = $group | Get-Random
			$filepart3 = $group | Get-Random
			$filepart4 = $FileTypes | Get-Random
			$filename = $filepart1 + $filepart2 + $filepart3 + '.' + $filepart4
			
			if ($SubDirectories)
			{
				$createchance = Get-Random -Maximum ($SubDirectoryCreateChance + 1) -Minimum 1
				if ($createchance -eq $SubDirectoryCreateChance)
				{
					$dirpick = Get-Random $directories
					if ($dirpick -eq 'create')
					{
						$pathpart1 = $verbs | Get-Random
						$pathpart2 = $group | Get-Random
						$pathpart3 = $pathpart1 + $pathpart2
						$directories += $pathpart3
						$dirPath = $Path + "\" + $pathpart3
						New-Item -Path $dirPath -Type dir -ErrorAction SilentlyContinue | Out-Null
					}
					else
					{
						$dirpath = $Path + "\" + $dirpick
					}
					$filepath = $dirPath + "\" + $filename
					Write-Verbose $filepath
				}
				else
				{
					$filepath = $Path + "\" + $filename
				}
			}
			else
			{
				$filepath = $Path + "\" + $filename
			}
			if ($Variance)
			{
				$rnd = Get-Random -Maximum 3 -Minimum 1
				$filesizechange = Get-Random -Maximum ($Variance + 1) -Minimum 1
				switch ($rnd)
				{
					'1' { $filesize += $filesizechange }
					'2'	{ $filesize -= $filesizechange }
				}
				if ($filesize -lt 0)
				{
					$filesize = 1
					$filesize / 1MB
				}
			}
			while (Test-Path $filepath)
			{
				$filepath = ($filepath.replace("." + $filepart4, 'Copy')) + "." + $filepart4
			}
			Remove-Variable tempsize -erroraction SilentlyContinue
			while ($TempSize -le $filesize)
			{
				Write-Verbose $filepath
				$null = $stringBuilder.Append($blockoftext)
				$filecontent.Add($stringBuilder)
				$filecontent | Out-File $filepath -Append -Encoding ASCII
				$tempsize = (Get-Item $filepath).length /1mb
			}
			
			Remove-Variable rnd, filepath, filesize, filesizechange, pathpart1, pathpart2, pathpart3, dirpath -erroraction SilentlyContinue
			$CreatedFileCount++
		}
	}
	End
	{
		
	}
}
Clear-Host

<#Examples
Create-Files -Path c:\Temp\blog -FileTypes log, log1, log2, log3, log4, log5, log6, log7, log8 -Size 10 -Count 50 -Variance 4 -SubDirectories True -SubDirectoryCreateChance 10
Create-Files -Path c:\Temp\blog -FileTypes log, log1, log2, log3, log4, log5, log6, log7, log8 -Size 2 -Count 1000 -Variance 2 -SubDirectories True -SubDirectoryCreateChance 25
Create-Files -Path c:\Temp\blog -FileTypes log, log1, log2, log3, log4, log5, log6, log7, log8 -Size 4 -Count 1000 -Variance 2 -SubDirectories True -SubDirectoryCreateChance 25
Create-Files -Path c:\Temp\blog -FileTypes log, log1, log2, log3, log4, log5, log6, log7, log8 -Size 1 -Count 20000 -SubDirectories True -SubDirectoryCreateChance 50
#>
Create-Files -Path c:\Temp\blog -FileTypes log, log1, log2, log3, log4, log5, log6, log7, log8 -Size 1 -Count 4000 -SubDirectories true -SubDirectoryCreateChance 80

