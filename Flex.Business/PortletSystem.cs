using Flex.Data.Enum;
using Flex.Data.Model;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Text;

namespace Flex.Business
{
    public class PortletSystem : CoreSystem<Portlet>
    {
         private DbContext _context;
         public PortletSystem(DbContext context)
            : base(context)
        {
            _context = context;
        }

         public List<Portlet> RetrivePortlets(long Id)
         {
             //var portlet = new List<Portlet>();
             try
             {
                var portlets = new CoreSystem<LinkRole>(_context).FindAll(x => x.RoleID == Id && x.Type == (int)LinkType.Portlet).Select(x=>x.LinkId).ToList();
                 var portlet = FindAll(x=> portlets.Contains(x.Id)).OrderBy(y=>y.Order).ToList();

                 return portlet;
             }
             catch (Exception ex)
             {
                 Logger.InfoFormat("Error Occurred. Details [{0}]", ex.ToString());
                 throw;
             }
         }
    }
}
