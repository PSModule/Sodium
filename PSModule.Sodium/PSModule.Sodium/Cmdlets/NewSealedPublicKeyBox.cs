using System;
using System.Text;
using System.Management.Automation;
using System.Security;
using PSModule.Sodium.Isolated;

namespace PSModule.Sodium
{
    [Cmdlet(VerbsCommon.New, "SealedPublicKeyBox")]
    [OutputType(typeof(string))]
    public class NewSealedPublicKeyBoxCommand : PSCmdlet
    {
        [Parameter(Mandatory = true)]
        public string Secret { get; set; }

        [Parameter(Mandatory = true)]
        public string PublicKey { get; set; }

        protected override void ProcessRecord()
        {
            var encryptedString = Convert.ToBase64String(
                SealedPublicKeyBoxHelper.Create(
                    Encoding.UTF8.GetBytes(Secret),
                    Convert.FromBase64String(PublicKey)
                )
            );
            WriteObject(encryptedString);
        }
    }
}
