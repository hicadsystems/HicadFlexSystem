using CustomerPortal.Util;
using Flex.Business;
using Flex.Data.Enum;
using Flex.Data.Model;
using Flex.Data.Utility;
using Flex.Data.ViewModel;
using ImageResizer;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.Entity;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Helpers;
using System.Web.Mvc;

namespace CustomerPortal.Controllers
{
    [AllowAnonymous]
    public class SignUpController : BaseController
    {
        // GET: SignUp
        public ActionResult Index()
        {
            GetReationShip();
            GetPolicyType();
            GetLocation();
            GetAgent();
            return View();
        }

        //public void Next(FormCollection form)
        //{
        //    try
        //    {
        //        var step = form["step"].ToString();

        //        switch (step)
        //        {
        //            case "1":
        //                BuildPersonal(form);
        //                break;
        //            case "2":
        //                BuildNextKin(form);
        //                break;
        //            default:
        //                break;
        //        }

        //    }
        //    catch (Exception ex)
        //    {
        //        Logger.ErrorFormat("Error Occurred. Details  [{0}--{1}]", ex.ToString(), ex.StackTrace);
        //        throw;
        //    }
        //}

        //private void BuildPersonal(FormCollection form)
        //{
        //    var newpolreg = new PesonalInfoBindingModel();

        //    newpolreg.Surname = form["Surname"].ToString();
        //    newpolreg.Othernames = form["OtherNames"].ToString();
        //    newpolreg.Phone = form["Phone"].ToString();
        //    newpolreg.Email = form["Email"].ToString();
        //    newpolreg.ResAddress = form["ResidentialAddress"].ToString();
        //    newpolreg.OfficeAddress = form["OfficeAddress"].ToString();
        //    newpolreg.PostalAddress = form["PostalAddress"].ToString();
        //    var dob = form["dob"].ToString();
        //    newpolreg.Dob = DateTime.ParseExact(dob,
        //                      "yyyy-MM-dd",
        //                       CultureInfo.InvariantCulture);
        //    newpolreg.Occupation = form["Occupation"].ToString();
        //    newpolreg.Amount = Convert.ToDecimal(form["Amount"].ToString());
        //    newpolreg.Frequency = form["contribFreq"].ToString();
        //    newpolreg.Duration = Convert.ToInt32(form["Duration"].ToString());
        //    newpolreg.Type = Flex.Data.Enum.Type.New;

        //    int poltye = 0;
        //    var ptype=form["policyType"].ToString();
        //    int.TryParse(ptype, out poltye);
        //    newpolreg.PolicyType = poltye;

        //    int loc = 0;
        //    var locatn = form["location"].ToString();
        //    int.TryParse(locatn, out loc);
        //    newpolreg.Location = loc;

        //    var signUpModel= new SignUpBindingModel();

        //    signUpModel.PersonalInfo=newpolreg;
        //    Session["SignUp"] = signUpModel;
        //}

        //private void BuildNextKin(FormCollection form)
        //{
        //    var nextofkinBen = new NextofKinBeneficiaryBindingModel();

        //    nextofkinBen.Name = form["Name"].ToString();
        //    nextofkinBen.Phone = form["Phone"].ToString();
        //    nextofkinBen.Address = form["Address"].ToString();
        //    nextofkinBen.Email = form["Email"].ToString();
        //    nextofkinBen.Category = Category.NextofKin;
        //    nextofkinBen.Type = Flex.Data.Enum.Type.New;
        //    var Nextdob = form["dob"].ToString();
        //    nextofkinBen.Dob = DateTime.ParseExact(Nextdob,
        //                      "yyyy-mm-dd",
        //                       CultureInfo.InvariantCulture);

        //    var nextofkinBenlist = new List<NextofKinBeneficiaryBindingModel>();

        //    //nextofkinBenlist = (List<NextofKinBeneficiaryBindingModel>)Session["beneficiaries"];

        //    nextofkinBenlist.Add(nextofkinBen);

        //    var signUpModel = Session["SignUp"] != null ? (SignUpBindingModel)Session["SignUp"] : new SignUpBindingModel();

        //    signUpModel.PersonalInfo.NextofKinBeneficiary = nextofkinBenlist;

        //    Session["SignUp"] = signUpModel;
        //}
        [HttpPost]
        public ActionResult SignUp2(SignUpBindingModel signUpmodel)
        {
            try { 
            string filenames = "";
            string fileName = "";
            string path = "";
            string fileName2 = "";
            string path2 = "";
                if (Session["IdentyNumber"] != null)
                {
                    if (Request != null)
                    {
                        HttpPostedFileBase FileUpload = Request.Files["PictureFile"];
                        if (FileUpload.ContentLength > 0)
                        {
                            fileName = "Passport_" + Session["IdentyNumber"] + ".png";
                            path = Path.Combine(Server.MapPath("~/Pictures/"), fileName);
                            //fileName= Path.GetFileName(FileUpload.FileName);
                            string fileExtension = System.IO.Path.GetExtension(Request.Files["PictureFile"].FileName.ToLower());
                            // path = Path.Combine(Server.MapPath("~/Content/UploadPhotoPath/"));
                            path = path.Replace("CustomerPortal", "Flex");
                            if (fileExtension == ".jpg" || fileExtension == ".jpeg" || fileExtension == ".gif" || fileExtension == ".png" || fileExtension == ".bmp")
                            {
                                if (System.IO.File.Exists(path))
                                {
                                    System.IO.File.Delete(path);
                                }
                                FileUpload.SaveAs(path);
                                WebImage img = new WebImage(path);
                                if (img.Width > 150)
                                    img.Resize(150, 150);
                                    img.Save(path);

                                ViewData["Feedback"] = "Upload Complete";

                            }
                        }

                       
                    }
                }
                Session["IdentyNumber"] = "";
            
                return RedirectToAction("Success");
        }
            catch (Exception ex)
            {
                Logger.ErrorFormat("Error Occurred. Details  [{0}--{1}]", ex.ToString(), ex.StackTrace);
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
    }

}

        [HttpPost]
        public ActionResult SignUp(SignUpBindingModel signUpmodel)
        {
            Logger.Info("Inside post signUp");
            try
            {
                if (signUpmodel == null)
                {
                    throw new Exception("Error Occurred.");
                }
                if (signUpmodel.PersonalInfo == null)
                {
                    throw new Exception("Error occurred. Please try again");
                }
                if (signUpmodel.PersonalInfo.IdentityNumber==null)
                {
                    throw new Exception("Please Provide Vilid ID and Number");
                }
                if (signUpmodel.PersonalInfo.Frequency == null)
                {
                    throw new Exception("Please Select Frequency From Tab One");
                }
                if (signUpmodel.PersonalInfo.NextofKin==null)
                {
                    throw new Exception("Please Provide Next of kin Details");
                }
                if (signUpmodel.PersonalInfo.Beneficiary==null || !signUpmodel.PersonalInfo.Beneficiary.Any())
                {
                    throw new Exception("Please Provide atleast one Beneficiary");
                }

                Session["IdentyNumber"] = signUpmodel.PersonalInfo.IdentityNumber;
                new SignUpSystem(context).SaveSignUp(signUpmodel.PersonalInfo);
                //var ben = JsonConvert.DeserializeObject<List<NextofKinBeneficiaryBindingModel>>(beneficiaries);

                //if (ben.Any())
                //{
                //    ben.ForEach(x => x.Type = Flex.Data.Enum.Type.New);
                //    ben.ForEach(x => x.Category = Category.Beneficiary);


                //    var signUpData = (SignUpBindingModel)Session["SignUp"];
                //    if (signUpData==null)
                //    {
                //        throw new Exception("Session Time Out. Try Again");
                //    }
                //    if (signUpData.PersonalInfo.NextofKinBeneficiary!= null)
                //    {
                //        signUpData.PersonalInfo.NextofKinBeneficiary.AddRange(ben);
                //    }

                //    new SignUpSystem(context).SaveSignUp(signUpData.PersonalInfo);
                //}
                //else
                //{
                //    throw new Exception("Please Provide atleast one Beneficiary");
                //}

                
                return new JsonResult(){
                    Data= new UrlHelper(Request.RequestContext).Action("uploaddoc")
                };
                   
            }
            catch (Exception ex)
            {
                Logger.ErrorFormat("Error Occurred. Details  [{0}--{1}]", ex.ToString(), ex.StackTrace);
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }
        public ActionResult uploaddoc()
        {
            return View();
        }

        public ActionResult Success()
        {
            return View();
        }

        [AllowAnonymous]
        public JsonResult UploadPicture(string term)
        {
            try
            {
                var pictureUrl = "";
                var fileName = "";
                var fileContent = Request.Files[0];
                //if (fileContent != null && fileContent.ContentLength > 0)
                //{
                //    // get a stream
                //    var stream = fileContent.InputStream;
                //    // and optionally write the file to disk
                //    fileName = Path.GetFileName(fileContent.FileName);
                //    var path = Path.Combine(ConfigurationManager.AppSettings["PicturePath"], fileName);
                //    using (var fileStream = System.IO.File.Create(path))
                //    {
                //        stream.CopyTo(fileStream);
                //    }
                //}

                var binarypic = convertTobyte(fileContent);
                var binarystringpic = Convert.ToBase64String(binarypic);

                pictureUrl = ConfigurationManager.AppSettings["BasePicUrl"] + fileName;

                var data = new
                {
                    //Url = pictureUrl,
                    Url = Convert.ToBase64String(binarypic),
                    //FileName = fileName
                    FileName = binarystringpic
                };
                return Json(data, JsonRequestBehavior.AllowGet);

            }
            catch (Exception)
            {

                throw;
            }
        }

        public byte[] convertTobyte(HttpPostedFileBase c)
        {
            byte[] imageBytes = null;
            BinaryReader reader = new BinaryReader(c.InputStream);
            imageBytes = reader.ReadBytes((int)c.ContentLength);
            return imageBytes;
        }
        private void GetReationShip()
        {
            var relationships = UtilEnumHelper.GetEnumList(typeof(RelationShip));
            ViewBag.relationships = new SelectList(relationships, "ID", "Name");

        }

        public ActionResult Validate(string phone)
        {
            try
            {
                var isValid = new PolicySystem(context).validate(phone);

                return new JsonResult()
                {
                    Data = isValid
                };
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Detail {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }
        public ActionResult ResetPassword()
        {
            return View();
        }
        [HttpPost]
        public ActionResult ResetPassword2(ChangePasswordBindingModel xpass)
        {
            try
            {
                var usrSession = WebSecurity.GetCurrentUser(Request);
                var custUser = new CoreSystem<CustomerUser>(context).FindAll(x => x.username == xpass.OldPassword).FirstOrDefault();
                string pass = custUser.password;

                JsonResult resp = null;
                var result = new CustomerAuthSystem(context).ResetPassword(custUser.Id, xpass.NewPassword, pass);
                resp = new JsonResult()
                {
                    Data = result,


                };

                return RedirectToAction("Index","Login");
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.ToString());
            }
        }
    }

}