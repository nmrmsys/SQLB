@ECHO OFF

REM  SQLB [FilePath] [ConStr]

REM �f�t�H���g�ڑ�������

REM ##### Oracle #####
REM SET DCS=usr/pwd@srv

REM ##### SQL Server #####
REM SET DCS=usr:pwd:db:srv\ins

REM �f�t�H���g�t�@�C���p�X
REM SET DFP=sql\*.sql

REM �ݒ�l
SET LOG=log
SET SP=sqlplus
SET ST=%~dp0_start
SET SC=sqlcmd

REM ��������
SET YMD=%date:~0,4%%date:~5,2%%date:~8,2%
SET HMS=%time: =0%
SET HMS=%HMS:~0,2%%HMS:~3,2%%HMS:~6,2%
SET FP=%DFP%
SET CS=%DCS%
SET DCS=
SET DFP=

SETLOCAL ENABLEDELAYEDEXPANSION

REM ��������
IF NOT "%1"=="" (
  SET FP=%1
)
IF NOT "%2"=="" (
  SET CS=%2
)
IF "%CS%"=="" (
  GOTO :USAGE
)
IF "%FP%"=="" (
  GOTO :USAGE
)

REM ���s����
CALL :SQLB %FP% %CS%

REM �ꊇ���s��
REM %~d0
REM CD %~dp0
REM CALL :SQLB private\func\*.sql usr1:pwd1:db:srv\ins
REM CALL :SQLB private\proc\*.sql usr1:pwd1:db:srv\ins
REM CALL :SQLB private\func\*.sql usr2:pwd2:db:srv\ins
REM CALL :SQLB private\proc\*.sql usr2:pwd2:db:srv\ins

GOTO :EOF

:USAGE
ECHO SQLB [FilePath] [ConStr]
GOTO :EOF

:SQLB

SET FP=%1
SET CS=%2

SET LP=%~dp0%LOG%

REM sql�t�H���_���ƂɃ��O�t�H���_�쐬
REM SET LP=%~dp1%LOG%

SET LF=%LP%\%YMD%_%HMS%.log
IF NOT EXIST %LP% (
  MD %LP%
  ECHO. > %LP%\$$$.log
)
REM ���O�t�@�C���폜
FOR /f "skip=19" %%F in ('dir /b /o-n %LP%\*.log') DO (
  IF EXIST %LP%\%%F DEL %LP%\%%F
)
IF EXIST %LP%\$$$.log DEL %LP%\$$$.log

IF "%CS::=%"=="%CS%" (
  SET TY=ORA
  FOR /f "delims=@ tokens=1-2" %%A in ("%CS%") DO (
    SET UP=%%A
    SET SV=%%B
  )
  FOR /f "delims=/ tokens=1-2" %%A in ("!UP!") DO (
    SET US=%%A
    SET DB=%%A
    SET PW=%%B
  )
  SET TL=%SP% -S %CS% @%ST%
) ELSE (
  SET TY=SQL
  FOR /f "delims=: tokens=1-4" %%A in ("%CS%") DO (
    SET US=%%A
    SET PW=%%B
    SET DB=%%C
    SET SV=%%D
  )
  SET TL=%SC% -U !US! -P !PW! -d !DB! -S !SV! -e -i
)
ECHO [%DB%@%SV%]
ECHO [%DB%@%SV%] >> %LF%
ECHO. >> %LF%

REM FOR %%F in (%FP%) DO (
FOR /f %%F in ('dir /b /s /on %FP%') DO (
  SET SF=%%~fF
  SET CMD=%TL% %%~fF
  
  REM �J�n���Ԃ̎擾
  REM SET T1=!TIME:/=!
  SET T1=!TIME: =0!
  SET H1=!T1:~0,2!
  SET M1=!T1:~3,2!
  SET S1=!T1:~6,2!
  
  REM 8�i�΍�
  set /a H1=1!H1!-100
  set /a M1=1!M1!-100
  set /a S1=1!S1!-100
  
  REM �������s
  ECHO !SF!
  ECHO !SF! >> %LF%
  REM ECHO !CMD!
  !CMD! >> %LF%
  ECHO. >> %LF%
  
  REM �I�����Ԃ̎擾
  SET T2=!TIME: =0!
  SET H2=!T2:~0,2!
  SET M2=!T2:~3,2!
  SET S2=!T2:~6,2!
  
  REM 8�i�΍�
  SET /a H2=1!H2!-100
  SET /a M2=1!M2!-100
  SET /a S2=1!S2!-100
  
  REM �o�ߎ��Ԃ̌v�Z
  SET /a H3=!H2!-!H1!
  
  SET /a M3=!M2!-%M1!
  IF !M3! LSS 0 SET /a H3=H3-1
  IF !M3! LSS 0 SET /a M3=M3+60
  
  SET /a S3=S2-S1
  IF !S3! LSS 0 SET /a M3=M3-1
  IF !S3! LSS 0 SET /a S3=S3+60
  
  REM �o�ߎ��Ԃ̑O0����
  SET H3=0!H3!
  SET H3=!H3:~-2!
  SET M3=0!M3!
  SET M3=!M3:~-2!
  SET S3=0!S3!
  SET S3=!S3:~-2!
  
  REM ���s���Ԃ̏o��
  ECHO START:!T1! END:!T2! ELAPSED:!H3!:!M3!:!S3!
  ECHO START:!T1! END:!T2! ELAPSED:!H3!:!M3!:!S3! >> %LF%
  ECHO. >> %LF%
)

GOTO :EOF
