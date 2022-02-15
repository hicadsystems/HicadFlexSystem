using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(CustomerPortal.Startup))]
namespace CustomerPortal
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }
    }
}
