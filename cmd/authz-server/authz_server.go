package main

import (
	"encoding/json"
	"flag"
	"log"
	"net"
	"strings"

	"golang.org/x/net/context"

	"github.com/gogo/googleapis/google/rpc"
	"google.golang.org/genproto/googleapis/rpc/status"
	"google.golang.org/grpc"

	coreV3 "github.com/envoyproxy/go-control-plane/envoy/config/core/v3"
	authV3 "github.com/envoyproxy/go-control-plane/envoy/service/auth/v3"
	typeV3 "github.com/envoyproxy/go-control-plane/envoy/type/v3"
)

var (
	grpcPort = flag.String("port", ":50051", "port")
)

type AuthorizationServer struct{}

func (a *AuthorizationServer) Check(ctx context.Context, req *authV3.CheckRequest) (*authV3.CheckResponse, error) {
	log.Println(">>> Authorization Check")

	b, err := json.MarshalIndent(req.Attributes.Request.Http.Headers, "", "  ")
	if err == nil {
		log.Println("Inbound Headers: ")
		log.Println(string(b))
	}

	mail, ok := req.Attributes.Request.Http.Headers["x-forwarded-email"]
	if !ok {
		// missing user ID passed form the OAuth proxy
		log.Println("Missing user ID passed form the OAuth proxy")
		return &authV3.CheckResponse{
			Status: &status.Status{
				Code: int32(rpc.UNAUTHENTICATED),
			},
			HttpResponse: &authV3.CheckResponse_DeniedResponse{
				DeniedResponse: &authV3.DeniedHttpResponse{
					Status: &typeV3.HttpStatus{
						Code: typeV3.StatusCode_Unauthorized,
					},
				},
			},
		}, nil
	}
	if !strings.HasSuffix(mail, "loodse.com") {
		// unauthorized user
		log.Printf("User %s NOT authorized\n", mail)
		return &authV3.CheckResponse{
			Status: &status.Status{
				Code: int32(rpc.PERMISSION_DENIED),
			},
			HttpResponse: &authV3.CheckResponse_DeniedResponse{
				DeniedResponse: &authV3.DeniedHttpResponse{
					Status: &typeV3.HttpStatus{
						Code: typeV3.StatusCode_Unauthorized,
					},
					Body: "PERMISSION_DENIED",
				},
			},
		}, nil
	}

	// parse OrgID from tbe original request path
	orgID := ""
	arr := strings.Split(req.Attributes.Request.Http.Path, "/")
	if len(arr) > 1 {
		orgID = arr[1]
	}
	if orgID == "" {
		log.Println("OrgID cannot be parsed")
		return &authV3.CheckResponse{
			Status: &status.Status{
				Code: int32(rpc.NOT_FOUND),
			},
			HttpResponse: &authV3.CheckResponse_DeniedResponse{
				DeniedResponse: &authV3.DeniedHttpResponse{
					Status: &typeV3.HttpStatus{
						Code: typeV3.StatusCode_NotFound,
					},
				},
			},
		}, nil
	}

	log.Printf("User %s authorized for tenat %s\n", mail, orgID)
	return &authV3.CheckResponse{
		Status: &status.Status{
			Code: int32(rpc.OK),
		},
		HttpResponse: &authV3.CheckResponse_OkResponse{
			OkResponse: &authV3.OkHttpResponse{
				Headers: []*coreV3.HeaderValueOption{
					{
						Header: &coreV3.HeaderValue{
							Key:   "X-Scope-OrgID",
							Value: orgID,
						},
					},
				},
			},
		},
	}, nil
}

func main() {
	flag.Parse()

	lis, err := net.Listen("tcp", *grpcPort)
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	s := grpc.NewServer()
	authV3.RegisterAuthorizationServer(s, &AuthorizationServer{})

	log.Printf("Starting gRPC Server at %s", *grpcPort)
	s.Serve(lis)
}
