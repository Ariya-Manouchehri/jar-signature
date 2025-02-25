package facade;

import jakarta.ejb.Stateless;
import jakarta.jws.WebService;

@WebService(serviceName = "ServiceFacade", name = "ServiceFacade")
@Stateless
public class ServiceFacade {

    public String test() {
        return "hello dear.";
    }
}
