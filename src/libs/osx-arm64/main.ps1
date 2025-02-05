# Load LibSodium native functions via P/Invoke (requires LibSodium library present)
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
namespace PSModule {
    public static class Sodium
    {
        [DllImport("libsodium", CallingConvention = CallingConvention.Cdecl)]
        public static extern int sodium_init();

        [DllImport("libsodium", CallingConvention = CallingConvention.Cdecl)]
        public static extern int crypto_box_keypair(byte[] pk, byte[] sk);

        [DllImport("libsodium", CallingConvention = CallingConvention.Cdecl)]
        public static extern int crypto_box_seal(byte[] ciphertext, byte[] message, ulong mlen, byte[] pk);

        [DllImport("libsodium", CallingConvention = CallingConvention.Cdecl)]
        public static extern int crypto_box_seal_open(byte[] decrypted, byte[] ciphertext, ulong clen, byte[] pk, byte[] sk);

        [DllImport("libsodium", CallingConvention = CallingConvention.Cdecl)]
        public static extern UIntPtr crypto_box_publickeybytes();

        [DllImport("libsodium", CallingConvention = CallingConvention.Cdecl)]
        public static extern UIntPtr crypto_box_secretkeybytes();

        [DllImport("libsodium", CallingConvention = CallingConvention.Cdecl)]
        public static extern UIntPtr crypto_box_sealbytes();
    }
}
'@ -PassThru

# 1. Initialize the library (call once at the start)
[void][PSModule.Sodium]::sodium_init()
