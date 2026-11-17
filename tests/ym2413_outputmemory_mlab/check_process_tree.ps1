$ErrorActionPreference='Stop'
Add-Type -TypeDefinition @'
using System;using System.Collections.Generic;using System.Runtime.InteropServices;
public class AutoProcessTree {
 [StructLayout(LayoutKind.Sequential,CharSet=CharSet.Unicode)] public struct Entry {
  public uint dwSize,cntUsage,th32ProcessID;public UIntPtr th32DefaultHeapID;
  public uint th32ModuleID,cntThreads,th32ParentProcessID;public int pcPriClassBase;public uint dwFlags;
  [MarshalAs(UnmanagedType.ByValTStr,SizeConst=260)] public string szExeFile;
 }
 [DllImport("kernel32.dll",SetLastError=true)] static extern IntPtr CreateToolhelp32Snapshot(uint flags,uint pid);
 [DllImport("kernel32.dll",CharSet=CharSet.Unicode)] static extern bool Process32FirstW(IntPtr snap,ref Entry e);
 [DllImport("kernel32.dll",CharSet=CharSet.Unicode)] static extern bool Process32NextW(IntPtr snap,ref Entry e);
 [DllImport("kernel32.dll")] static extern bool CloseHandle(IntPtr h);
 public static Entry[] List(){var h=CreateToolhelp32Snapshot(2,0);if(h==new IntPtr(-1))throw new Exception("Toolhelp snapshot failed");try{var all=new List<Entry>();var e=new Entry();e.dwSize=(uint)Marshal.SizeOf(e);if(Process32FirstW(h,ref e))do{all.Add(e);}while(Process32NextW(h,ref e));return all.ToArray();}finally{CloseHandle(h);}}
}
'@
$taskEntries=[AutoProcessTree]::List()
$taskGhdl=@($taskEntries | Where-Object {$_.szExeFile -ieq 'ghdl.exe'})
$taskRecords=@()
foreach($taskEntry in $taskGhdl){
 $taskProcess=Get-Process -Id $taskEntry.th32ProcessID -ErrorAction Stop
 if($taskProcess.PriorityClass -ne [Diagnostics.ProcessPriorityClass]::Idle){throw 'GHDL priority is not Idle'}
 $taskChildren=@($taskEntries | Where-Object {$_.th32ParentProcessID -eq $taskEntry.th32ProcessID})
 foreach($taskChild in $taskChildren){$taskCP=Get-Process -Id $taskChild.th32ProcessID;if($taskCP.PriorityClass -ne [Diagnostics.ProcessPriorityClass]::Idle){throw 'GHDL child is not Idle'}}
 $taskRecords+=@{PID=$taskEntry.th32ProcessID;ParentPID=$taskEntry.th32ParentProcessID;Priority="$($taskProcess.PriorityClass)";Children=@($taskChildren | Select-Object th32ProcessID,szExeFile,th32ParentProcessID)}
}
@{Timestamp=(Get-Date -Format o);Method='Toolhelp32 snapshot; CIM unavailable';PASS=$true;Processes=$taskRecords} | ConvertTo-Json -Depth 5 | Set-Content "$PSScriptRoot/process_tree_check.json"
Write-Output "PASS Toolhelp process-tree check: GHDL=$($taskRecords.Count), all Idle"
