using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(Flex.Startup))]
namespace Flex
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            //ConfigureAuth(app);
        }
    }
}
