# Create-RandomFiles
This function will supply any number of files approximately at the size you request.  Rather than setting a file size, this function actually fills the files with text until they reach the requested size.  You can control the number of files, size of files, and whether or not to create random sub-directories.

<#
	.SYNOPSIS
		Creates a number of auto-generated files in the spcified directories.
	
	.DESCRIPTION
		This function will supply any number of files approximately at the size you request.  Rather than setting a file size, this function actually fills the files with text until they reach the requested size.  You can control the number of files, size of files, and whether or not to create random sub-directories.
	
	.PARAMETER Path
		The top level path where the script will begin to create files.   C:\Temp, for example.
	
	.PARAMETER FileTypes
		The types of files to create.  This parameter expects an array of values.  For example:  'log','log1','log2'
	
	.PARAMETER Size
		Size of each individual file.  This parmeter is added to, or subtracted from, by the variance parameter.  This value is in Mb.  Exact sizes will vary, and larger file sizes will lead to larger variance
	
	.PARAMETER Variance
		This parameter is added to, or subtracted from, the Size parameter to get a semi-random file size.  Blocks of text are added to the files, so exact file sizes will be random within a range.
	
	.PARAMETER SubDirectories
		Specify if this script should create subdirectories under the directory specified by the Path parameter.  Directories will have random names similar to file names, and there is a random chance of them being created (specified by the SubDirectoryCreateChance parameter)
	
	.PARAMETER Count
		The number of files to create under the directory specified by the Path parameter
	
	.PARAMETER SubDirectoryCreateChance
		The chance that a subdirectory will be created.  Larger numbers here will actually make it less likely that a subdirectory is created.  A number of 20 means that 1-in-20 will create a subdirectory.  A number of 100 means that 1-100 will create a subdirectory.
	
	.PARAMETER SizeMeasurement
		The measurement type that is used for both the file size and the variance.  Valid values are KB, MB, GB.  
	
	.EXAMPLE
		PS C:\> Create-Files -Path c:\Temp\blog -FileTypes log, log1, log2, log3, log4, log5, log6, log7, log8 -Size 3 -Count 100
	
	.EXAMPLE
		PS C:\> Create-Files -Path c:\Temp\blog -FileTypes log, log1, log2, log3, log4, log5, log6, log7, log8 -Size 1 -Count 20000 -SubDirectories True -SubDirectoryCreateChance 50
	
	.EXAMPLE
		PS C:\> Create-Files -Path c:\Temp\blog -FileTypes log, log1, log2, log3, log4, log5, log6, log7, log8 -Size 10 -Count 50 -Variance 4 -SubDirectories True -SubDirectoryCreateChance 10
	
	.NOTES
		Exact sizes aren't possible with this method, since we are adding actual text to the files.  If exact sizes are necessary, you can create a blank file with the appropriate size.
#>
