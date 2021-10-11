%% This is the application resource file (.app file) for the 'base'
%% application.
{application, boot_strap,
[{description, "Boot service for raspberry boards" },
{vsn, "0.1.0" },
{modules, 
	  [boot_strap,boot_strap_sup,boot_strap_server]},
{registered,[boot_strap]},
{applications, [kernel,stdlib]},
{mod, {boot_strap,[]}},
{start_phases, []},
{git_path,"https://github.com/joq62/boot_strap.git"},
{env,[{git_path_start,"https://github.com/joq62/controller.git"},
      {parent_dir,"applications"},
      {log_source_dir,"log"},
      {log_backup_dir,"logs"},
      {log_file_ext,".log"}
      ]}
]}.
