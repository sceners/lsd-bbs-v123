{ =========================================================================== }
{ DESQ42.pas - Unit to interface DESQview with TP 4.0       ver 4.2, 10-01-88 }
{                                                                             }
{ These are the routines that are published by Quarterdeck and have been      }
{ adapted for use in Turbo Pascal.  Only 95 bytes of code.                    }
{  by  James H. LeMay, CIS 76011,217                                          }
{  for Eagle Performance Software                                             }
{      P.O. Box 122237                                                        }
{      Ft. Worth, TX  76121                                                   }
{                                                                             }
{ Version 1.0 (06-05-88)                                                      }
{  - Initial release                                                          }
{ Version 4.2 (10-01-88)                                                      }
{  - Made In_DV a global variable with initialization to FALSE                }
{  - Revised DESQqwik.pas for QWIK42.TPU                                      }
{ =========================================================================== }

{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

UNIT DESQ42;

INTERFACE

var
  In_DV: boolean;

function  DV_Get_Version: word;
function  DV_Get_Video_Buffer (VideoSeg: word): word;
procedure DV_Pause;
procedure DV_Begin_Critical;
procedure DV_End_Critical;

IMPLEMENTATION

{$L DESQ42.obj }
function  DV_Get_Version;      external;
function  DV_Get_Video_Buffer; external;
procedure DV_Pause;            external;
procedure DV_Begin_Critical;   external;
procedure DV_End_Critical;     external;

BEGIN
  In_DV := false;    { allows correct in memory compiling }
END.
