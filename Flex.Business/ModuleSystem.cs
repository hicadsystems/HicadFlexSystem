using Flex.Data.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.Entity;

namespace Flex.Business
{
    public class ModuleSystem : CoreSystem<Module>
    {
        private DbContext _context;
        public ModuleSystem(DbContext context) : base(context)
        {
            _context = context;
        }

        public List<Module> GetModules()
        {
            Logger.Info("Inside GetModules");
            try
            {
                return GetAll().ToList();
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error getting Modules. Details {0}", ex.ToString());
                throw;
            }
        }

        public List<string> GetModulesPolicyTypes(string moduleCode)
        {
            try
            {
                var module = FindAll(x => x.Code == moduleCode).FirstOrDefault();
                if (module== null)
                {
                    throw new Exception(string.Format("Invalid Module with Code [{0}]", moduleCode));
                }

                var polTypes = module.PolicyType.Split(new char[] { ';' }, StringSplitOptions.RemoveEmptyEntries);

                return polTypes.ToList();
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error getting Modules PolicyTypes. Details {0}", ex.ToString());
                throw;
            }
        }
    }
}
