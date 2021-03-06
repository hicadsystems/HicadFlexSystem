using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.Entity;
using System.Linq.Expressions;
using log4net;
using Insurance.Data.ViewModel;

namespace Insurance.Business
{
    public class CoreSystem<T> where T: class
    {
        private DbContext _context;
        private static DbContext scontext;
        private readonly ISet<T> _Set;
        public ILog Logger { get { return log4net.LogManager.GetLogger("Insurance"); } }

        public CoreSystem(DbContext context)
        {
            _context = context;
            scontext = context;
        }
        public IQueryable<T> GetAll()
        {
            return _context.Set<T>();
        }

        public void Save(T t)
        {
            _context.Set<T>().Add(t);
            _context.SaveChanges();
        }

        public IQueryable<T> FindAll(Expression<Func<T, bool>> match)
        {
            return _context.Set<T>().Where(match);
        }
        public PagedResult<T> PagedQuery(Func<T, dynamic> order, IQueryable<T> query, int xPage = 0, int xPagesize = 0)
        {
            var TotalCount = 0;
            xPagesize = xPagesize > 0 ? xPagesize : 10;
            xPage = xPage > 0 ? xPage : 1;
            TotalCount = query.Count();
            var skip = (xPage - 1) * xPagesize;
            var PagedTrans = new PagedResult<T>()
            {
                LongRowCount = TotalCount,
                Items = query.OrderBy(order).Skip(skip).Take(xPagesize).ToList(),
                PageSize = xPagesize,
                PageCount = TotalCount > 0 ? (int)Math.Ceiling(Convert.ToDouble(Convert.ToDouble(TotalCount) / Convert.ToDouble(xPagesize))) : 1,
                CurrentPage = xPage
            };

            return PagedTrans;
        }

        public T Update(T updated, int key)
        {
            if (updated == null)
                return null;

            T existing = _context.Set<T>().Find(key);
            if (existing != null)
            {
                _context.Entry(existing).CurrentValues.SetValues(updated);
                _context.SaveChanges();
            }
            return existing;
        }

        public T Update(T updated, long key)
        {
            if (updated == null)
                return null;

            T existing = _context.Set<T>().Find(key);
            if (existing != null)
            {
                _context.Entry(existing).CurrentValues.SetValues(updated);
                _context.SaveChanges();
            }
            return existing;
        }

        public T Get(int id)
        {
            return _context.Set<T>().Find(id);
        }

        public T Get(long id)
        {
            return _context.Set<T>().Find(id);
        }

        public long Count()
        {
            return _context.Set<T>().Count();
        }

        public void Delete(T t)
        {
            _context.Entry(t).State = EntityState.Deleted;
            _context.SaveChanges();
        }
    }
}
