allprojects {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

rootProject.buildDir = file("../build")

subprojects {
    project.buildDir = File(rootProject.buildDir, project.name)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}
