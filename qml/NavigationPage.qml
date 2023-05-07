import QtQuick

import "pages"
import "pages/Plant"
import "pages/Insect"
import "pages/Auth"
import "pages/Garden"

QtObject {
    property var plantIdentifierPage: Component {
        PlantIdentifier {}
    }
    property var posometrePage: Component {
        Posometre {}
    }
    property var deseasePage: Component {
        PlantDesease {}
    }
    property var deseaseEncyclopedie: Component {
        PlantDeseaseEncylopedie {}
    }
    property var deseaseDetailsPage: Component {
        PlantDeseaseDetails {}
    }
    property var plantBrowserPage: Component {
        PlantBrowser {}
    }
    property var plantDetailPage: Component {
        PlantScreenDetails {}
    }
    property var plantSearchPage: Component {
        PlantSearch {}
    }
    property var insectDetailPage: Component {
        InsectDetailsScreen {}
    }
    property var loginPage: Component {
        Login {}
    }
    property var registerPage: Component {
        Register {}
    }
    property var gardenPlantsList: Component {
        GardenPlantsList {}
    }
    property var gardenSpacesList: Component {
        GardenSpacesList {}
    }
    property var gardenSpaceDetails: Component {
        GardenSpaceDetails {}
    }
}
