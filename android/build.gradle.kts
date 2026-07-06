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

    // file_picker's flutter_plugin_android_lifecycle dependency requires
    // compileSdk 36+; the bundled Flutter Gradle plugin still defaults every
    // Android library subproject (plugins) to 34. :app already sets its own
    // compileSdk directly, and evaluationDependsOn forces it to evaluate
    // early (before this block runs for it), so skip it here.
    if (project.name != "app") {
        afterEvaluate {
            extensions.findByType(com.android.build.gradle.BaseExtension::class.java)?.let {
                it.compileSdkVersion(36)
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
