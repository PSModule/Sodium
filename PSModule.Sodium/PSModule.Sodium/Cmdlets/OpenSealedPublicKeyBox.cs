using System;
using System.Text;
using System.Management.Automation;
using PSModule.Sodium.Isolated;

namespace PSModule.Sodium
{
    [Cmdlet(VerbsCommon.Open, "SealedPublicKeyBox")]
    [OutputType(typeof(string))]
    public class OpenSealedPublicKeyBoxCommand : PSCmdlet
    {
        [Parameter(
            Mandatory = true,
            Position = 0,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        public string EncryptedSecret { get; set; }

        [Parameter(
            Mandatory = true,
            Position = 1,
            ValueFromPipelineByPropertyName = true)]
        public string PrivateKey { get; set; }

        [Parameter(
            Mandatory = true,
            Position = 1,
            ValueFromPipelineByPropertyName = true)]
        public string PublicKey { get; set; }

        protected override void ProcessRecord()
        {
            var decryptedString = Encoding.UTF8.GetString(
                SealedPublicKeyBox.Open(
                    Convert.FromBase64String(EncryptedSecret),
                    Convert.FromBase64String(PublicKey),
                    Convert.FromBase64String(PrivateKey)
                )
            );
            WriteObject(decryptedString);
        }
    }
}
