%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(boot_loader).  
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%%---------------------------------------------------------------------
%% Records for test
%%


%% --------------------------------------------------------------------
-compile(export_all).


%% ====================================================================
%% External functions
%% ====================================================================
boot(ControllerGitPath,ParentDir,LogSource,LogBackUp,FileExtension)-> 
    start_copy_files(ParentDir,LogSource,FileExtension,LogBackUp),
    ok=scratch_host(ParentDir),
    os:cmd("mkdir "++ParentDir),
    {ok,ControllerEbin}=git_clone(ControllerGitPath,controller,ParentDir),
    true=code:add_patha(ControllerEbin),
    ok=application:start(controller),
    
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
scratch_host(ParentDir)->
    []=os:cmd("rm -rf "++ParentDir),
    ok.

start_copy_files(ParentDir,LogSource,FileExtension,LogBackUp)->
    case filelib:is_dir(ParentDir) of
	false->
	    ok=file:make_dir(ParentDir);
	true->
	    nop
    end,
    case filelib:is_dir(LogBackUp) of
	false->
	    ok=file:make_dir(LogBackUp);
	true->
	    nop
    end,
    os:cmd("rm -f"++LogBackUp++"/*"),
    {ok,Files}=file:list_dir(ParentDir),
    LogFileDirs=[{File,filename:join([ParentDir,File,LogSource])}||File<-Files,
							    true=:=filelib:is_dir(filename:join(ParentDir,File))],
    
    copy_dirs(LogFileDirs,FileExtension,LogBackUp,[]).


copy_dirs([],_FileExtension,_LogBackUp,Result)->
    Result;
copy_dirs([{AppDir,LogFileDir}|T],FileExtension,LogBackUp,Acc)->
    {ok,Files}=file:list_dir(LogFileDir),
    LogFiles=[{AppDir,File}||File<-Files,
		    FileExtension=:=filename:extension(filename:join(LogFileDir,File))],
    AppBackupLogDir=filename:join(LogBackUp,AppDir),
    file:make_dir(AppBackupLogDir),
    Result=copy_files(LogFiles,LogFileDir,AppBackupLogDir,[]),
    copy_dirs(T,FileExtension,LogBackUp,[Result|Acc]).


copy_files([],_LogFileDir,_AppBackupLogDir,CopyResults)->
    Result=case [R||R<-CopyResults,
		    R/=ok] of
	       []->
		   ok;
	       Errors->
		   {error,[Errors]}
	   end,
    Result;

copy_files([{AppDir,File}|T],LogFileDir,AppBackupLogDir,Acc)->
    
    NewAcc=case file:copy(filename:join(LogFileDir,File),filename:join(AppBackupLogDir,File)) of
	       {ok,_}->
		   [ok|Acc];
	       Error ->
		   ErrMsg={error,[{code,Error},
			   {info,File,LogFileDir,AppBackupLogDir},
			   {file,?MODULE,?FUNCTION_NAME,?LINE}]},
		   [ErrMsg|Acc]
	   end,
    copy_files(T,LogFileDir,AppBackupLogDir,NewAcc).
						      
						      
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
git_clone(GitPath,Application,ParentDir)->
    ApplicationPath=filename:join(ParentDir,atom_to_list(Application)),
    os:cmd("git clone "++GitPath++" "++ApplicationPath),
    AppEbin=filename:join(ApplicationPath,"ebin"),
    Result=case filelib:is_dir(AppEbin) of
	       true->
		   {ok,AppEbin};
	       false->
		   {error,[{code,eexists},
			   {info,AppEbin,GitPath,Application,ParentDir},
			   {file,?MODULE,?FUNCTION_NAME,?LINE}]}
	   end,
    Result.
    
    
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
