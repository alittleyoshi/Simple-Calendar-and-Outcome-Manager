import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Node;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.SceneAntialiasing;
import javafx.stage.Stage;

public class App extends Application {
    public static void main(String[] args) {
        launch(args);
    }
    @Override
    public void start(Stage primaryStage) throws Exception {
        FXMLLoader loader = new FXMLLoader(App.class.getResource("/ui/main scene.fxml"));
        Parent parent = loader.load();
        Scene scene = new Scene(parent, parent.prefWidth(-1), parent.prefHeight(-1), true);
        primaryStage.setScene(scene);
        primaryStage.show();
    }
}
