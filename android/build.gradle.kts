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
    project.evaluationDependsOn(":app")
}

subprojects {
    val configureCompileSdk: () -> Unit = {
        project.extensions.findByName("android")?.let { ext ->
            val methods = ext.javaClass.methods
            val setter = methods.firstOrNull { 
                (it.name == "compileSdkVersion" || it.name == "setCompileSdkVersion" || it.name == "setCompileSdk") &&
                it.parameterCount == 1 &&
                (it.parameterTypes[0] == java.lang.Integer.TYPE || it.parameterTypes[0] == java.lang.Integer::class.java)
            }
            setter?.invoke(ext, 36)
        }
    }
    if (project.state.executed) {
        configureCompileSdk()
    } else {
        project.afterEvaluate { configureCompileSdk() }
    }
}


tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

