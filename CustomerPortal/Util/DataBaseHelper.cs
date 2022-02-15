using Flex.Data.Model;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;

namespace CustomerPortal.Util
{
    public static class DataBaseHelper
    {
        public static FlexEntities dbcontext
        {
            get
            {
                return new FlexEntities();
            }
        }
    }
}