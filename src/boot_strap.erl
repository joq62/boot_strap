%% Author: uabjle
%% Created: 10 dec 2012
%% Description: TODO: Add description to application_org
-module(boot_strap).

-behaviour(application).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Behavioural exports
%% --------------------------------------------------------------------
-export([
	 boot/0,
	 start/2,
	 stop/1
        ]).

%% --------------------------------------------------------------------
%% Internal exports
%% --------------------------------------------------------------------
-export([

	]).

%% --------------------------------------------------------------------
%% Macros
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Records
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% API Functions
%% --------------------------------------------------------------------
boot()->
    application:start(?MODULE).

%% ====================================================================!
%% External functions
%% ====================================================================!
%% --------------------------------------------------------------------
%% Func: start/2
%% Returns: {ok, Pid}        |
%%          {ok, Pid, State} |
%%          {error, Reason}
%% --------------------------------------------------------------------
start(_Type, _StartArgs) ->
    ok=init(),
    {ok,Pid}= boot_strap_sup:start_link(),
    {ok,Pid}.
   
%% --------------------------------------------------------------------
%% Func: stop/1
%% Returns: any
%% --------------------------------------------------------------------
stop(_State) ->
    ok.

%% ====================================================================
%% Internal functions
%% ====================================================================
init()->
    Appfile=atom_to_list(?MODULE)++".app",
    Env=appfile:read(Appfile,env),
    {git_path_start,GitPath}=lists:keyfind(git_path_start,1,Env),
    ok=application:set_env(?MODULE,git_path_start,GitPath), 

    {parent_dir,ParentDir}=lists:keyfind(parent_dir,1,Env),
    ok=application:set_env(?MODULE,parent_dir,ParentDir), 

    {log_source_dir,Source}=lists:keyfind(log_source_dir,1,Env),
    ok=application:set_env(?MODULE,log_source_dir,Source), 

    {log_backup_dir,Backup}=lists:keyfind(log_backup_dir,1,Env),
    ok=application:set_env(?MODULE,log_backup_dir,Backup), 
    {log_file_ext,Ext}=lists:keyfind(log_file_ext,1,Env),
    ok=application:set_env(?MODULE,log_file_ext,Ext),

    ok.
