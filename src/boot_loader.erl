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
boot(ControllerGitPath,ParentDir)-> 
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
