class SodiumIsolatedAssemblyLoadContext : System.Runtime.Loader.AssemblyLoadContext {
    SodiumIsolatedAssemblyLoadContext() : base($true) { }

    [System.Reflection.Assembly] LoadFromAssemblyPath([string]$assemblyPath) {
        return $this.LoadFromAssemblyPath($assemblyPath)
    }
}
