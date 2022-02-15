using CrystalDecisions.CrystalReports.Engine;
using CrystalDecisions.Shared;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Dynamic;
using System.IO;
//using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Web;
using System.Web.Mvc;

namespace Flex.Controllers.Util
{
    public class ReportFileActionResult : ActionResult
    {
        
        private readonly byte[] _contentBytes;

        String ContentType=null;
        string FileName = null;

        public ReportFileActionResult(FileInfo fileInfo, string downloadFileName, String contentType)
            : this(fileInfo.OpenRead(), downloadFileName, contentType)
        { }
        public ReportFileActionResult(Stream fileStream, string downloadFileName, String contentType)
        {
            _contentBytes = StreamToBytes(fileStream);
            ContentType = contentType;
            FileName = downloadFileName;
        }


        public ReportFileActionResult(String fileContent, string downloadFileName, String contentType)
            : this(new MemoryStream(Encoding.UTF8.GetBytes(fileContent)), downloadFileName, contentType)
        { }
    
        public override void ExecuteResult(ControllerContext context)
        {

            var response = context.HttpContext.ApplicationInstance.Response;
            response.Clear();
            response.Buffer = false;
            response.ClearContent();
            response.ClearHeaders();
            response.Cache.SetCacheability(HttpCacheability.Public);
            response.ContentType = ContentType;


            var cd = new System.Net.Mime.ContentDisposition
            {
                FileName = FileName,
                Inline = false,
            };
            response.AppendHeader("Content-Disposition", cd.ToString());

            //var stream = new MemoryStream(_contentBytes);
            //stream.Seek(0, SeekOrigin.Begin);
            //return File(stream, ContentType, FileName);
        }

 
        private static byte[] StreamToBytes(Stream input)
        {
            byte[] buffer = new byte[16 * 1024];
            using (MemoryStream ms = new MemoryStream())
            {
                int read;
                while ((read = input.Read(buffer, 0, buffer.Length)) > 0)
                {
                    ms.Write(buffer, 0, read);
                }
                return ms.ToArray();
            }
        }
    }
}