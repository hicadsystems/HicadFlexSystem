using CustomerPortal.Filters;
using System.Web;
using System.Web.Mvc;

namespace CustomerPortal
{
    public class FilterConfig
    {
        public static void RegisterGlobalFilters(GlobalFilterCollection filters)
        {
            filters.Add(new HandleErrorAttribute());
            filters.Add(new AuthFilter());
        }
    }
}
