using Flex.Data.Model;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Text;

namespace Flex.Business
{
    public class TabSystem : CoreSystem<Tab>
    {
        private DbContext _context;

        public TabSystem(DbContext context)
            : base(context)
        {
            _context = context;
        }

        public IList RetrieveTabs(int PortletId)
        {
            try
            {
                var tabs = FindAll(x => x.PortletId == PortletId).OrderBy(x=>x.Order).ToList();

                return tabs;
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error Occurred. Details [{0}]",ex.ToString());
                throw;
            }
        }

        public IList RetrieveTabs(List<int> TabIds)
        {
            try
            {
                var tabs = FindAll(x => TabIds.Contains(x.Id)).Include(y=>y.Portlet).OrderBy(x => x.Order).ToList();

                return tabs;
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error Occurred. Details [{0}]", ex.ToString());
                throw;
            }
        }

    }
}
