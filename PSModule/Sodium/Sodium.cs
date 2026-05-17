using System;
using System.Runtime.InteropServices;

namespace PSModule
{
    public static partial class Sodium
    {
        private static partial class Native
        {
            [LibraryImport("libsodium")]
            [DefaultDllImportSearchPaths(DllImportSearchPath.AssemblyDirectory | DllImportSearchPath.SafeDirectories)]
            [UnmanagedCallConv(CallConvs = new[] { typeof(System.Runtime.CompilerServices.CallConvCdecl) })]
            public static partial int sodium_init();

            [LibraryImport("libsodium")]
            [DefaultDllImportSearchPaths(DllImportSearchPath.AssemblyDirectory | DllImportSearchPath.SafeDirectories)]
            [UnmanagedCallConv(CallConvs = new[] { typeof(System.Runtime.CompilerServices.CallConvCdecl) })]
            public static partial int crypto_box_keypair([Out] byte[] publicKey, [Out] byte[] privateKey);

            [LibraryImport("libsodium")]
            [DefaultDllImportSearchPaths(DllImportSearchPath.AssemblyDirectory | DllImportSearchPath.SafeDirectories)]
            [UnmanagedCallConv(CallConvs = new[] { typeof(System.Runtime.CompilerServices.CallConvCdecl) })]
            public static partial int crypto_box_seed_keypair([Out] byte[] publicKey, [Out] byte[] privateKey, byte[] seed);

            [LibraryImport("libsodium")]
            [DefaultDllImportSearchPaths(DllImportSearchPath.AssemblyDirectory | DllImportSearchPath.SafeDirectories)]
            [UnmanagedCallConv(CallConvs = new[] { typeof(System.Runtime.CompilerServices.CallConvCdecl) })]
            public static partial int crypto_box_seal([Out] byte[] ciphertext, byte[] message, ulong mlen, byte[] publicKey);

            [LibraryImport("libsodium")]
            [DefaultDllImportSearchPaths(DllImportSearchPath.AssemblyDirectory | DllImportSearchPath.SafeDirectories)]
            [UnmanagedCallConv(CallConvs = new[] { typeof(System.Runtime.CompilerServices.CallConvCdecl) })]
            public static partial int crypto_box_seal_open([Out] byte[] decrypted, byte[] ciphertext, ulong ciphertextLength, byte[] publicKey, byte[] privateKey);

            [LibraryImport("libsodium")]
            [DefaultDllImportSearchPaths(DllImportSearchPath.AssemblyDirectory | DllImportSearchPath.SafeDirectories)]
            [UnmanagedCallConv(CallConvs = new[] { typeof(System.Runtime.CompilerServices.CallConvCdecl) })]
            public static partial UIntPtr crypto_box_publickeybytes();

            [LibraryImport("libsodium")]
            [DefaultDllImportSearchPaths(DllImportSearchPath.AssemblyDirectory | DllImportSearchPath.SafeDirectories)]
            [UnmanagedCallConv(CallConvs = new[] { typeof(System.Runtime.CompilerServices.CallConvCdecl) })]
            public static partial UIntPtr crypto_box_secretkeybytes();

            [LibraryImport("libsodium")]
            [DefaultDllImportSearchPaths(DllImportSearchPath.AssemblyDirectory | DllImportSearchPath.SafeDirectories)]
            [UnmanagedCallConv(CallConvs = new[] { typeof(System.Runtime.CompilerServices.CallConvCdecl) })]
            public static partial UIntPtr crypto_box_sealbytes();

            [LibraryImport("libsodium")]
            [DefaultDllImportSearchPaths(DllImportSearchPath.AssemblyDirectory | DllImportSearchPath.SafeDirectories)]
            [UnmanagedCallConv(CallConvs = new[] { typeof(System.Runtime.CompilerServices.CallConvCdecl) })]
            public static partial UIntPtr crypto_box_seedbytes();

            [LibraryImport("libsodium")]
            [DefaultDllImportSearchPaths(DllImportSearchPath.AssemblyDirectory | DllImportSearchPath.SafeDirectories)]
            [UnmanagedCallConv(CallConvs = new[] { typeof(System.Runtime.CompilerServices.CallConvCdecl) })]
            public static partial int crypto_scalarmult_base([Out] byte[] publicKey, byte[] privateKey);
        }

        // libsodium guarantees these *_bytes() functions return constants and are safe to call without sodium_init().
        private static readonly int PublicKeyBytes = GetRequiredLength(Native.crypto_box_publickeybytes());
        private static readonly int SecretKeyBytes = GetRequiredLength(Native.crypto_box_secretkeybytes());
        private static readonly int SealBytes = GetRequiredLength(Native.crypto_box_sealbytes());
        private static readonly int SeedBytes = GetRequiredLength(Native.crypto_box_seedbytes());

        public static int sodium_init()
        {
            return Native.sodium_init();
        }

        public static int crypto_box_keypair(byte[] publicKey, byte[] privateKey)
        {
            ValidateMinimumBufferLength(publicKey, PublicKeyBytes, nameof(publicKey));
            ValidateMinimumBufferLength(privateKey, SecretKeyBytes, nameof(privateKey));

            return Native.crypto_box_keypair(publicKey, privateKey);
        }

        public static int crypto_box_seed_keypair(byte[] publicKey, byte[] privateKey, byte[] seed)
        {
            ValidateMinimumBufferLength(publicKey, PublicKeyBytes, nameof(publicKey));
            ValidateMinimumBufferLength(privateKey, SecretKeyBytes, nameof(privateKey));
            ValidateExactBufferLength(seed, SeedBytes, nameof(seed));

            return Native.crypto_box_seed_keypair(publicKey, privateKey, seed);
        }

        public static int crypto_box_seal(byte[] ciphertext, byte[] message, ulong mlen, byte[] publicKey)
        {
            ValidateMinimumBufferLength(message, mlen, nameof(message));
            ValidateMinimumBufferLength(ciphertext, checked(mlen + (ulong)SealBytes), nameof(ciphertext));
            ValidateExactBufferLength(publicKey, PublicKeyBytes, nameof(publicKey));

            return Native.crypto_box_seal(ciphertext, message, mlen, publicKey);
        }

        public static int crypto_box_seal_open(byte[] decrypted, byte[] ciphertext, ulong ciphertextLength, byte[] publicKey, byte[] privateKey)
        {
            var sealBytes = (ulong)SealBytes;
            if (ciphertextLength < sealBytes)
            {
                throw new ArgumentException($"The ciphertext must be at least {sealBytes} bytes.", nameof(ciphertext));
            }

            ValidateMinimumBufferLength(ciphertext, ciphertextLength, nameof(ciphertext));
            ValidateMinimumBufferLength(decrypted, ciphertextLength - sealBytes, nameof(decrypted));
            ValidateExactBufferLength(publicKey, PublicKeyBytes, nameof(publicKey));
            ValidateExactBufferLength(privateKey, SecretKeyBytes, nameof(privateKey));

            return Native.crypto_box_seal_open(decrypted, ciphertext, ciphertextLength, publicKey, privateKey);
        }

        public static UIntPtr crypto_box_publickeybytes()
        {
            return (UIntPtr)PublicKeyBytes;
        }

        public static UIntPtr crypto_box_secretkeybytes()
        {
            return (UIntPtr)SecretKeyBytes;
        }

        public static UIntPtr crypto_box_sealbytes()
        {
            return (UIntPtr)SealBytes;
        }

        public static UIntPtr crypto_box_seedbytes()
        {
            return (UIntPtr)SeedBytes;
        }

        public static int crypto_scalarmult_base(byte[] publicKey, byte[] privateKey)
        {
            ValidateMinimumBufferLength(publicKey, PublicKeyBytes, nameof(publicKey));
            ValidateExactBufferLength(privateKey, SecretKeyBytes, nameof(privateKey));

            return Native.crypto_scalarmult_base(publicKey, privateKey);
        }

        private static int GetRequiredLength(UIntPtr length)
        {
            var value = length.ToUInt64();
            if (value > int.MaxValue)
            {
                throw new OverflowException("The Sodium buffer length exceeds the maximum supported array length.");
            }

            return (int)value;
        }

        private static void ValidateExactBufferLength(byte[] buffer, int expectedLength, string parameterName)
        {
            ArgumentNullException.ThrowIfNull(buffer, parameterName);

            if (buffer.Length != expectedLength)
            {
                throw new ArgumentException($"The buffer must be exactly {expectedLength} bytes.", parameterName);
            }
        }

        private static void ValidateMinimumBufferLength(byte[] buffer, int minimumLength, string parameterName)
        {
            ValidateMinimumBufferLength(buffer, (ulong)minimumLength, parameterName);
        }

        private static void ValidateMinimumBufferLength(byte[] buffer, ulong minimumLength, string parameterName)
        {
            ArgumentNullException.ThrowIfNull(buffer, parameterName);

            if ((ulong)buffer.LongLength < minimumLength)
            {
                throw new ArgumentException($"The buffer must be at least {minimumLength} bytes.", parameterName);
            }
        }
    }
}
