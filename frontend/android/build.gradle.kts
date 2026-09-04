allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    afterEvaluate {
        val androidExt = extensions.findByName("android") ?: return@afterEvaluate
        try {
            androidExt.javaClass.getMethod("setCompileSdkVersion", Int::class.javaPrimitiveType)
                .invoke(androidExt, 36)
        } catch (_: Throwable) {
            try {
                androidExt.javaClass.getMethod("setCompileSdk", Int::class.javaPrimitiveType)
                    .invoke(androidExt, 36)
            } catch (_: Throwable) {
                // ignore plugins without a mutable compileSdk
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
