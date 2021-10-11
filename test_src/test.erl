%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description :  1
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(test).   
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
%-include_lib("eunit/include/eunit.hrl").
%% --------------------------------------------------------------------

%% External exports
-export([start/0]). 


%% ====================================================================
%% External functions
%% ====================================================================


%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
start()->
    io:format("~p~n",[{"Start setup",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=setup(),
    io:format("~p~n",[{"Stop setup",?MODULE,?FUNCTION_NAME,?LINE}]),

    io:format("~p~n",[{"Start t1()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=t1(),
    io:format("~p~n",[{"Stop t1()",?MODULE,?FUNCTION_NAME,?LINE}]),

%    io:format("~p~n",[{"Start pass1()",?MODULE,?FUNCTION_NAME,?LINE}]),
%    ok=pass1(),
%    io:format("~p~n",[{"Stop pass1()",?MODULE,?FUNCTION_NAME,?LINE}]),

 %   
      %% End application tests
    io:format("~p~n",[{"Start cleanup",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=cleanup(),
    io:format("~p~n",[{"Stop cleaup",?MODULE,?FUNCTION_NAME,?LINE}]),
   
    io:format("------>"++atom_to_list(?MODULE)++" ENDED SUCCESSFUL ---------"),
    ok.



%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
t1()->
    os:cmd("rm -rf applications"),
    ok=file:make_dir("applications"),
    ok=file:make_dir("applications/app1"),
    ok=file:make_dir("applications/app1/log"),
    ok=file:make_dir("applications/app2"),
    ok=file:make_dir("applications/app2/log"),   
  %  ok=application:start(boot_strap),
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
pass1()->
   
    
    ok.



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
pass_2()->
    
     ok.



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

setup()->
    HostId=net_adm:localhost(),
    A="a@"++HostId,
    NodeA=list_to_atom(A),
    B="b@"++HostId,
    NodeB=list_to_atom(B),
    C="c@"++HostId,
    NodeC=list_to_atom(C),    
    Nodes=[NodeA,NodeB,NodeC],
    [rpc:call(Node,init,stop,[])||Node<-Nodes],
    Cookie=atom_to_list(erlang:get_cookie()),
    Args="-pa ebin -setcookie "++Cookie,
    [{ok,NodeA},
     {ok,NodeB},
     {ok,NodeC}]=[slave:start(HostId,NodeName,Args)||NodeName<-["a","b","c"]],
    
   ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------    

cleanup()->
  
  %  application:stop(etcd),
  %  init:stop(),
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
