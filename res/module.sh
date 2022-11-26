__BEGIN_SOURCE__

# Downloads a remote module from github and returns the path to the file 
#
# Usage: <namespace>.load_module [opts] <repository>
#
# Options:
#   --dest/-d <path>            Download the module to the specified path
#                               Default: ${cwd}/lib
#   --github-url <url>          Provide a URL for Github Enterprise users
#                               Default: https://github.com
#   --branch <name>             Download the module from the specified branch
#                               Default: Repository main branch
#
# Examples:
#   Download the github-actions-helpers module to ./lib/github-actions-helpers.lib.sh 
#   and returns the relative path to the module, then sources it in to the running script's
#   context.
#
#   source module "techjavelin/github-actions-helpers"
function __NAMESPACE__.load_module() {
    return
}

__END_SOURCE__