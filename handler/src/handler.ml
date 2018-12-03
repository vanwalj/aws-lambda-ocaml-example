let handler _ = Lwt.return (AwsLambda.Bootstrap.Success "{}")

let () = Lwt_main.run (AwsLambda.Bootstrap.run handler)
