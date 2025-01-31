
using Sodium;

namespace PSModule.Sodium.Isolated
{
    public class SealedPublicKeyBoxHelper
    {
        public static byte[] Create(byte[] byteArr, byte[] publicKey)
        {
            return SealedPublicKeyBox.Create(byteArr, publicKey);
        }
    }
}
