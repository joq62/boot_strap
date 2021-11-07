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
-define(BootConfig,"boot.config").
-define(InfraAppConfig,"infra_app.config").

%% --------------------------------------------------------------------
-compile(export_all).


%% ====================================================================
%% External functions
%% ====================================================================
initial_boot()-> 
    {ok,CleanCreateDirsResult}=clean_create_dirs(),
    {ok,StartVmList}=start_vms(),
    {ok,CloneInfo}=clone(),
    {ok,StartInfo}=start_infra_apps(CloneInfo),
     
    {ok,[StartInfo,CloneInfo,CleanCreateDirsResult,StartVmList]}.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
start_infra_apps(CloneInfo)->
    {ok,I}=file:consult(?InfraAppConfig),  
    AppVm=proplists:get_value(application_vmid,I),
    StartList=[{App,misc_node:node(VmId)}||{App,VmId}<-AppVm],
    AppEbin=[{list_to_atom(AppId),Ebin}||{ok,AppId,Ebin,_GitInfo}<-CloneInfo],
    FullList=[{App,Node,proplists:get_value(App,AppEbin)}||{App,Node}<-StartList],
    {ok,start_app(FullList)}.

start_app(FullList)->
    start_app(FullList,[]).

start_app([],StartResult)->
    StartResult;
start_app([{Application,Vm,undefined}|T],Acc)->
    start_app(T,[{{error,[undefined]},Vm,Application}|Acc]);
start_app([{Application,Vm,Ebin}|T],Acc)->
    
 %   io:format("Application,Vm,Ebin ~p~n",[{Application,Vm,Ebin,?MODULE,?FUNCTION_NAME,?LINE}]),
 %   io:format("file:list_dir(Ebin) ~p~n",[{Application,Vm,Ebin,rpc:call(Vm,file,list_dir,[Ebin]),?MODULE,?FUNCTION_NAME,?LINE}]),
    
    true=rpc:call(Vm,code,add_patha,[Ebin],2000),
    R=rpc:call(Vm,application,start,[Application],3*5000),
%    io:format("App start ~p~n",[{R,?MODULE,?FUNCTION_NAME,?LINE}]),
    start_app(T,[{R,Application,Vm,Ebin}|Acc]).

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
clean_create_dirs()->
    {ok,I}=file:consult(?BootConfig),    
    NodesToStart=proplists:get_value(nodes_to_start,I),
    DirsToCleanCreate=[Dir||{_Host,Dir,_Args}<-NodesToStart],
    DirsToKeep=proplists:get_value(dirs_to_keep,I),
    R=[clean_create_dir(Dir,DirsToKeep)||Dir<-DirsToCleanCreate],
    {ok,R}.

clean_create_dir(Dir,Keep)->
    %Keep [Files or DirNames]
    Result=case filelib:is_dir(Dir) of
	       false->
		   file:make_dir(Dir),
		   {ok,[created,Dir]};
	       true-> %Clean up 
		   {ok,FileNames}=file:list_dir(Dir),
		   FilesToRemove=[filename:join(Dir,FileName)||FileName<-FileNames,
							       false=:=lists:member(FileName,Keep)],
		   [os:cmd("rm -rf "++FileToRemove)||FileToRemove<-FilesToRemove],
		   {ok,[clean_up,FilesToRemove]}
	   end,
    Result.
			      
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
start_vms()->
    {ok,I}=file:consult(?BootConfig),   
    NodesToStart=proplists:get_value(nodes_to_start,I),
    SortedStart=lists:sort(spawn_vm(NodesToStart)),
    {ok,SortedStart}.

spawn_vm(StartList)->
    F1=fun spawn_vm/2,
    F2=fun check/3,
    StartResult=mapreduce:start(F1,F2,[],StartList),
    Result=case [Node||{ok,Node}<-StartResult] of
	       []->
		   {ok,StartResult};
	       Nodes->
		   [{net_kernel:connect_node(Node),Node}||Node<-Nodes]
	   end,
    Result. 

spawn_vm(Parent,{Host,Name,Args})->
    X=slave:start(Host,Name,Args),
 %   io:format("X ~p~n",[X]),
    Parent!{spawn_vm,X}.

check(spawn_vm,Vals,_)->
    check(Vals,[]).
check([],Result)->
    Result;
check([StartResult|T],Acc)->
    check(T,[StartResult|Acc]).
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
clone()->
    {ok,I}=file:consult(?InfraAppConfig),    
    StartList=proplists:get_value(applications_to_start,I),
    CloneList=[{AppId,AppId,GitPath}||{AppId,_Vsn,GitPath}<-StartList],
    {ok,clone(CloneList,[])}.

clone([],R)->
    R;
clone([{Dir,Application,GitPath}|T],Acc)->
    io:format("{Dir,Application,GitPath ~p~n",[{Dir,Application,GitPath}]),
    AppDir=filename:join(Dir,Application),
    case filelib:is_dir(AppDir) of
	true->
	    os:cmd("rm -rf "++AppDir);
	false->
	    ok
    end,
    ok=file:make_dir(AppDir),
    
    GitInfo=os:cmd("git clone "++GitPath++" "++AppDir),
    Ebin=filename:join(AppDir,"ebin"),
    %check if app file is present 
    
    AppFile=filename:join([Ebin,Application++".app"]),
    true=filelib:is_file(AppFile),
    clone(T,[{ok,Application,Ebin,GitInfo}|Acc]).


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
