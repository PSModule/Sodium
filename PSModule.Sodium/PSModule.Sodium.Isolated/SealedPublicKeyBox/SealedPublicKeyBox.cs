
using Sodium;

namespace PSModule.Sodium.Isolated
{
    public class SealedPublicKeyBox
    {
        public static byte[] Create(byte[] secret, byte[] publicKey)
        {
            return global::Sodium.SealedPublicKeyBox.Create(secret, publicKey);
        }

        public static byte[] Open(byte[] cipher, byte[] publicKey, byte[] secretKey)
        {
            return global::Sodium.SealedPublicKeyBox.Open(cipher, publicKey, secretKey);
        }
    }
}
